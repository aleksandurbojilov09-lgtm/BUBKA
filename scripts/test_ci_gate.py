import os, subprocess, sys, unittest
from pathlib import Path

class GateTests(unittest.TestCase):
    def gate(self, **overrides):
        env=dict(os.environ,GITHUB_EVENT_NAME='pull_request',CLASSIFY='success',DOCS='success',COMMON_REQUIRED='true',COMMON_RESULT='success',ANDROID_REQUIRED='true',ANDROID_RESULT='success',IOS_REQUIRED='true',IOS_RESULT='success')
        env.update(overrides)
        return subprocess.run([sys.executable,str(Path(__file__).with_name('ci_gate.py'))],env=env,capture_output=True).returncode
    def test_full(self): self.assertEqual(self.gate(),0)
    def test_docs(self): self.assertEqual(self.gate(COMMON_REQUIRED='false',COMMON_RESULT='skipped',ANDROID_REQUIRED='false',ANDROID_RESULT='skipped',IOS_REQUIRED='false',IOS_RESULT='skipped'),0)
    def test_lite(self): self.assertEqual(self.gate(ANDROID_REQUIRED='false',ANDROID_RESULT='skipped',IOS_REQUIRED='false',IOS_RESULT='skipped'),0)
    def test_native(self): self.assertEqual(self.gate(IOS_REQUIRED='false',IOS_RESULT='skipped'),0)
    def test_main_lite_rejected(self): self.assertNotEqual(self.gate(GITHUB_EVENT_NAME='push',ANDROID_REQUIRED='false',ANDROID_RESULT='skipped',IOS_REQUIRED='false',IOS_RESULT='skipped'),0)
    def test_manual_lite_rejected(self): self.assertNotEqual(self.gate(GITHUB_EVENT_NAME='workflow_dispatch',ANDROID_REQUIRED='false',ANDROID_RESULT='skipped',IOS_REQUIRED='false',IOS_RESULT='skipped'),0)
    def test_common_failed_despite_successful_builds(self): self.assertNotEqual(self.gate(COMMON_RESULT='failure'),0)
    def test_common_cancelled_despite_successful_builds(self): self.assertNotEqual(self.gate(COMMON_RESULT='cancelled'),0)
    def test_failed(self): self.assertNotEqual(self.gate(ANDROID_RESULT='failure'),0)
    def test_cancelled(self): self.assertNotEqual(self.gate(IOS_RESULT='cancelled'),0)
    def test_required_skipped(self): self.assertNotEqual(self.gate(COMMON_RESULT='skipped'),0)
    def test_classification_failed(self): self.assertNotEqual(self.gate(CLASSIFY='failure'),0)
    def test_docs_failed(self): self.assertNotEqual(self.gate(DOCS='failure'),0)
    def test_empty_output(self): self.assertNotEqual(self.gate(IOS_REQUIRED=''),0)
    def test_unexpected_success(self): self.assertNotEqual(self.gate(IOS_REQUIRED='false'),0)
    def test_invalid_plan(self): self.assertNotEqual(self.gate(COMMON_REQUIRED='false',COMMON_RESULT='skipped'),0)
    def test_unknown_event(self): self.assertNotEqual(self.gate(GITHUB_EVENT_NAME='pull_request_target'),0)

if __name__=='__main__': unittest.main()
