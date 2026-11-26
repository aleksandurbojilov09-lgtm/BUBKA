import unittest
from ci_classify import classify, FULL

class ClassificationTests(unittest.TestCase):
    def test_docs(self): self.assertEqual(classify(['README.md','docs/handoffs/PHASE-02.json']), (False,False,False))
    def test_dart(self): self.assertEqual(classify(['lib/features/fuel/presentation/screens/fuel.dart']), (True,False,False))
    def test_android(self): self.assertEqual(classify(['android/app/src/main/AndroidManifest.xml']), (True,True,False))
    def test_ios(self): self.assertEqual(classify(['ios/Runner/AppDelegate.swift']), (True,False,True))
    def test_mixed(self): self.assertEqual(classify(['android/a.kt','ios/a.swift']), FULL)
    def test_renamed_out_of_code(self): self.assertEqual(classify(['lib/main.dart','docs/old.md']), FULL)
    def test_full(self):
        for p in ['pubspec.lock','lib/core/database/db.dart','assets/a.png','.github/workflows/ci.yml','ios/Podfile','unknown','scripts/version.py']:
            self.assertEqual(classify([p]),FULL)
    def test_empty(self): self.assertEqual(classify([]),FULL)

if __name__ == '__main__': unittest.main()
