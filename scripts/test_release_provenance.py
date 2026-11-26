import copy
import datetime as dt
import hashlib
import json
from pathlib import Path
import tempfile
import unittest
import zipfile
from release_provenance import validate_run, validate_jobs, select_artifacts, verify_archive, metadata, JOBS, CI_PATH

class ProvenanceTests(unittest.TestCase):
    def setUp(self):
        self.sha='a'*40; self.now=dt.datetime(2026,1,1,tzinfo=dt.timezone.utc)
        self.run=dict(id=1,head_sha=self.sha,head_branch='main',path=CI_PATH,workflow_id=3,status='completed',conclusion='success',event='push',repository={'id':2},head_repository={'id':2},run_attempt=2)
        self.jobs=[dict(name=n,run_id=1,run_attempt=2,head_sha=self.sha,status='completed',conclusion='success') for n in JOBS]
        self.assets=[dict(id=i,name=f'BUBKA-1.0.0-5-{p}-unsigned-attempt-2',expired=False,expires_at='2026-01-02T00:00:00Z',digest='sha256:'+'b'*64,workflow_run=dict(id=1,repository_id=2,head_repository_id=2,head_branch='main',head_sha=self.sha)) for i,p in enumerate(('android','ios'),10)]
    def select(self): return select_artifacts(self.assets,1,2,self.sha,2,'1.0.0','5',self.now)
    def test_good(self):
        self.assertEqual(validate_run(self.run,self.sha,2,3,1),2); validate_jobs(self.jobs,1,2,self.sha); self.assertEqual(self.select()['android']['id'],10)
    def test_wrong_run(self):
        for k,v in [('head_sha','c'*40),('event','pull_request'),('head_branch','dev'),('workflow_id',4),('status','in_progress'),('head_repository',{'id':9})]:
            r=dict(self.run,**{k:v})
            with self.assertRaises(ValueError): validate_run(r,self.sha,2,3,1)
    def test_wrong_attempt_or_skip(self):
        for k,v in [('run_attempt',1),('conclusion','skipped'),('head_sha','c'*40)]:
            jobs=copy.deepcopy(self.jobs); jobs[-1][k]=v
            with self.assertRaises(ValueError): validate_jobs(jobs,1,2,self.sha)
    def test_rerun_no_old_artifact(self):
        self.assets[0]['name']=self.assets[0]['name'].replace('attempt-2','attempt-1')
        with self.assertRaises(ValueError): self.select()
    def test_expired(self):
        self.assets[0]['expires_at']='2025-01-01T00:00:00Z'
        with self.assertRaises(ValueError): self.select()
    def test_expired_flag(self):
        self.assets[0]['expired']=True
        with self.assertRaises(ValueError): self.select()
    def test_duplicate(self):
        self.assets.append(dict(self.assets[0],id=99))
        with self.assertRaises(ValueError): self.select()
    def test_missing_digest(self):
        self.assets[0]['digest']=None
        with self.assertRaises(ValueError): self.select()
    def test_wrong_artifact_sha(self):
        self.assets[0]['workflow_run']['head_sha']='c'*40
        with self.assertRaises(ValueError): self.select()
    def test_archive(self):
        with tempfile.TemporaryDirectory() as d:
            d=Path(d); archive=d/'a.zip'; name='BUBKA-1.0.0+5-unsigned.apk'; meta=metadata('android','1.0.0','5',1,2,self.sha)
            with zipfile.ZipFile(archive,'w') as z:
                z.writestr(name,b'payload'); z.writestr('SHA256SUMS.txt',hashlib.sha256(b'payload').hexdigest()+'  '+name+'\n'); z.writestr('PROVENANCE.json',json.dumps(meta))
            digest='sha256:'+hashlib.sha256(archive.read_bytes()).hexdigest()
            verify_archive(archive,digest,d/'valid','android','1.0.0','5',meta)
            with self.assertRaises(ValueError): verify_archive(archive,'sha256:'+'a'*64,d/'bad','android','1.0.0','5',meta)
            with self.assertRaises(ValueError): verify_archive(archive,digest,d/'old','android','1.0.0','5',dict(meta,attempt=1))
    def test_inner_checksum(self):
        with tempfile.TemporaryDirectory() as d:
            d=Path(d); archive=d/'a.zip'; name='BUBKA-1.0.0+5-unsigned.apk'; meta=metadata('android','1.0.0','5',1,2,self.sha)
            with zipfile.ZipFile(archive,'w') as z:
                z.writestr(name,b'wrong'); z.writestr('SHA256SUMS.txt','0'*64+'  '+name); z.writestr('PROVENANCE.json',json.dumps(meta))
            with self.assertRaises(ValueError): verify_archive(archive,'sha256:'+hashlib.sha256(archive.read_bytes()).hexdigest(),d/'bad','android','1.0.0','5',meta)

if __name__=='__main__': unittest.main()
