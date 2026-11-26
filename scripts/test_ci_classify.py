import os
import subprocess
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch
from ci_classify import classify, version_only, event_plan, FULL, DOC, LITE

class ClassificationTests(unittest.TestCase):
    def test_docs(self): self.assertEqual(classify(['README.md','docs/handoffs/PHASE-03A.json']), DOC)
    def test_dart(self):
        for p in ['lib/features/fuel/presentation/screens/fuel.dart','lib/features/fuel/domain/fuel.dart','lib/features/fuel/data/fuel_repository.dart','test/fuel.dart','integration_test/fuel.dart']:
            self.assertEqual(classify([p]), LITE)
            self.assertEqual(classify([p], 'push'), FULL)
    def test_android(self): self.assertEqual(classify(['android/app/src/main/AndroidManifest.xml']), (True,True,False))
    def test_ios(self): self.assertEqual(classify(['ios/Runner/AppDelegate.swift']), (True,False,True))
    def test_mixed(self): self.assertEqual(classify(['android/app/src/main/AndroidManifest.xml','lib/features/x/domain/x.dart']), FULL)
    def test_native_both(self): self.assertEqual(classify(['android/app/src/main/AndroidManifest.xml','ios/Runner/AppDelegate.swift']), FULL)
    def test_delete_rename(self): self.assertEqual(classify(['lib/features/x/domain/x.dart','docs/old.md'],destructive=['lib/features/x/domain/x.dart']), FULL)
    def test_full(self):
        for p in ['pubspec.lock','lib/core/database/db.dart','assets/a.png','.github/workflows/ci.yml','ios/Podfile','unknown','scripts/version.py','lib/features/fuel/data/migration.dart','lib/features/fuel/data/schema.dart']:
            self.assertEqual(classify([p]),FULL)
    def test_empty(self): self.assertEqual(classify([]),FULL)
    def test_version(self):
        self.assertTrue(version_only(b'name: app\nversion: 1.0.0+1\n',b'name: app\nversion: 1.0.1+2\n'))
        self.assertFalse(version_only(b'name: app\nversion: 1.0.0+1\n',b'name: app2\nversion: 1.0.1+2\n'))
        self.assertEqual(classify(['pubspec.yaml','lib/app/version.dart'],version_ok=True),LITE)
        self.assertEqual(classify(['pubspec.yaml','pubspec.lock'],version_ok=True),FULL)
        self.assertEqual(classify(['pubspec.yaml']),FULL)
    def test_main(self): self.assertEqual(classify(['README.md'],'push'),DOC)

class EventTests(unittest.TestCase):
    def setUp(self):
        self.temp=tempfile.TemporaryDirectory(); self.old=os.getcwd(); os.chdir(self.temp.name)
        self.g('init','-q','-b','main'); self.g('config','user.email','ci@example.invalid'); self.g('config','user.name','CI test'); self.g('config','commit.gpgsign','false')
        self.base=self.write('README.md','base')
    def tearDown(self): os.chdir(self.old); self.temp.cleanup()
    def g(self,*args): return subprocess.check_output(['git',*args],stderr=subprocess.STDOUT,text=True).strip()
    def write(self,p,value):
        f=Path(p); f.parent.mkdir(parents=True,exist_ok=True); f.write_text(value); self.g('add','.'); self.g('commit','-qm',p); return self.g('rev-parse','HEAD')
    def test_synthetic_merge(self):
        self.g('switch','-qc','feature'); source=self.write('lib/features/x/domain/x.dart','x'); self.g('switch','-q','main'); base=self.write('README.md','other'); self.g('merge','--no-ff','-qm','merge','feature'); head=self.g('rev-parse','HEAD')
        event={'pull_request':{'base':{'sha':base,'ref':'main'},'head':{'sha':source}}}
        self.assertEqual(event_plan(event,'pull_request',head),LITE)
        event['pull_request']['base']['sha']=self.base
        with self.assertRaises(ValueError): event_plan(event,'pull_request',head)
    def test_schema_content_in_ordinary_path(self):
        self.g('switch','-qc','feature'); source=self.write('lib/features/x/data/x.dart','CREATE TABLE x (id INT)'); self.g('switch','-q','main'); self.g('merge','--no-ff','-qm','merge','feature'); head=self.g('rev-parse','HEAD')
        self.assertEqual(event_plan({'pull_request':{'base':{'sha':self.base,'ref':'main'},'head':{'sha':source}}},'pull_request',head),FULL)
    def test_push_reverted_risk(self):
        self.write('unknown','x'); self.g('rm','unknown'); self.g('commit','-qm','remove'); head=self.write('README.md','new')
        self.assertEqual(event_plan({'ref':'refs/heads/main','before':self.base,'after':head},'push',head),FULL)
    def test_push_docs_and_new(self):
        head=self.write('README.md','new'); event={'ref':'refs/heads/main','before':self.base,'after':head}
        self.assertEqual(event_plan(event,'push',head),DOC)
        event['created']=True; self.assertEqual(event_plan(event,'push',head),FULL)
    def test_dispatch(self):
        with patch.dict(os.environ,{'GITHUB_REF':'refs/heads/main'}): self.assertEqual(event_plan({},'workflow_dispatch',self.base),FULL)
        with patch.dict(os.environ,{'GITHUB_REF':'refs/heads/feature'}):
            with self.assertRaises(ValueError): event_plan({},'workflow_dispatch',self.base)

if __name__ == '__main__': unittest.main()
