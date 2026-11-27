import os
import subprocess
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch
from ci_classify import classify, version_only, event_plan, range_plan, export_only, FULL, DOC, LITE

class ClassificationTests(unittest.TestCase):
    def test_docs(self): self.assertEqual(classify(['README.md','docs/handoffs/PHASE-03A.json']), DOC)
    def test_dart(self):
        for p in ['lib/features/fuel/presentation/screens/fuel.dart','lib/features/fuel/domain/fuel.dart','lib/features/fuel/data/fuel_repository.dart','test/fuel.dart','integration_test/fuel.dart']:
            self.assertEqual(classify([p]), LITE)
            self.assertEqual(classify([p], 'push'), FULL)
    def test_android(self): self.assertEqual(classify(['android/app/src/main/AndroidManifest.xml']), FULL)
    def test_ios(self): self.assertEqual(classify(['ios/Runner/AppDelegate.swift']), FULL)
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

class ExportTests(unittest.TestCase):
    setUp = EventTests.setUp
    tearDown = EventTests.tearDown
    g = EventTests.g
    write = EventTests.write
    barrel = 'lib/features/garage/garage.dart'
    old_exports = ("export 'domain/garage_models.dart';\n"
                   "export 'presentation/garage_view_model.dart';\n"
                   "export 'presentation/vehicle_form.dart';\n")
    new_exports = old_exports + "export 'domain/vehicle_rules.dart';\n"

    def start_pr(self):
        for path in ('domain/garage_models.dart', 'presentation/garage_view_model.dart',
                     'presentation/vehicle_form.dart', 'domain/vehicle_rules.dart'):
            self.write('lib/features/garage/' + path, 'class Safe {}\n')
        self.base = self.write(self.barrel, self.old_exports)
        self.g('switch', '-qc', 'feature')

    def finish_pr(self):
        source = self.g('rev-parse', 'HEAD')
        self.g('switch', '-q', 'main')
        self.g('merge', '--no-ff', '-qm', 'merge', 'feature')
        head = self.g('rev-parse', 'HEAD')
        event = {'pull_request': {'base': {'sha': self.base, 'ref': 'main'}, 'head': {'sha': source}}}
        return event_plan(event, 'pull_request', head)

    def test_verified_export(self):
        self.start_pr()
        self.write(self.barrel, self.new_exports)
        self.assertEqual(self.finish_pr(), LITE)

    def test_export_not_verified_by_filename(self):
        self.assertEqual(classify([self.barrel]), FULL)
        self.assertEqual(classify(['lib/features/garage/other.dart'], verified_exports=['lib/features/garage/other.dart']), FULL)

    def test_unsafe_export_shapes(self):
        self.start_pr()
        self.write('lib/features/garage/domain/schema.dart', 'class Safe {}')
        for line in ("export '../other/domain/x.dart';", "export 'package:other/x.dart';",
                     "export 'domain/../x.dart';", "export 'domain/missing.dart';",
                     "export 'domain/schema.dart';", "export 'domain/vehicle_rules.dart' if (dart.library.io) 'data/x.dart';",
                     "class Extra {}", "part 'domain/vehicle_rules.dart';"):
            with self.subTest(line=line):
                head = self.write(self.barrel, self.old_exports + line + '\n')
                self.assertFalse(export_only(head, self.barrel))
        self.assertEqual(self.finish_pr(), FULL)

    def test_unsafe_export_reverted(self):
        self.start_pr()
        self.write(self.barrel, self.old_exports + "export 'package:other/x.dart';\n")
        self.write(self.barrel, self.new_exports)
        self.assertEqual(self.finish_pr(), FULL)

    def test_unsafe_target_content(self):
        self.start_pr()
        self.write('lib/features/garage/domain/vehicle_rules.dart', 'const channel = MethodChannel("x");')
        self.write(self.barrel, self.new_exports)
        self.assertEqual(self.finish_pr(), FULL)

    def test_mixed_dependency(self):
        self.start_pr()
        self.write(self.barrel, self.new_exports)
        self.write('pubspec.lock', 'changed')
        self.assertEqual(self.finish_pr(), FULL)

    def test_actual_pr7_path_fixture(self):
        paths = ['AGENTS.md', 'CHANGELOG.md', 'DECISIONS.md', 'KNOWN_ISSUES.md',
                 'PROJECT_STATE.json', 'ROADMAP.md', 'docs/garage-catalog.md',
                 'docs/handoffs/PHASE-05.json', 'lib/app/version.dart',
                 'lib/features/garage/data/local_garage_repository.dart',
                 'lib/features/garage/domain/garage_models.dart',
                 'lib/features/garage/domain/vehicle_rules.dart', self.barrel,
                 'lib/features/garage/presentation/vehicle_form.dart', 'pubspec.yaml',
                 'test/garage_flow_test.dart', 'test/garage_repository_test.dart']
        self.assertEqual(classify(paths, version_ok=True), FULL)
        self.assertEqual(classify(paths, version_ok=True, verified_exports=[self.barrel]), LITE)
        self.assertEqual(classify(paths, 'push', True, verified_exports=[self.barrel]), FULL)
        for risk in ('pubspec.lock', 'lib/core/database/database.dart', 'android/app/src/main/AndroidManifest.xml',
                     'ios/Runner/AppDelegate.swift', '.github/workflows/ci.yml', 'scripts/sign-release-apk.sh', 'unknown'):
            with self.subTest(risk=risk):
                self.assertEqual(classify(paths + [risk], version_ok=True, verified_exports=[self.barrel]), FULL)


class HistoricalPR7Tests(unittest.TestCase):
    def test_actual_pr7_git_range(self):
        base = 'cdc5626832808d006eb7d03c87f8a111edaeb37a'
        head = '73857439121386f7578452cb3041da4fc137cdcf'
        if subprocess.run(['git', 'cat-file', '-e', head + '^{commit}'], capture_output=True).returncode:
            if os.environ.get('GITHUB_ACTIONS') == 'true':
                self.fail('PR #7 history missing from full CI checkout')
            self.skipTest('PR #7 history unavailable in local checkout')
        self.assertEqual(range_plan(base, head, 'pull_request'), LITE)
        self.assertEqual(range_plan(base, head, 'push'), FULL)


if __name__ == '__main__': unittest.main()
