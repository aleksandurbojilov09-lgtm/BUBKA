#!/usr/bin/env bash
set -Eeuo pipefail
cd "$(git rev-parse --show-toplevel)"
[[ $(git branch --show-current) == phase/03-installation-updates ]]
command -v flutter
command -v dart
flutter pub get --enforce-lockfile
dart format lib test integration_test
dart run build_runner build
dart run drift_dev make-migrations
dart format lib test integration_test
python3 scripts/version.py check
python3 scripts/check_docs.py
python3 scripts/check_architecture.py
python3 scripts/test_ci_classify.py
python3 scripts/test_ci_gate.py
git diff --check
flutter analyze --no-pub --fatal-infos --fatal-warnings
flutter test --no-pub
git add -- lib test integration_test drift_schemas
if ! git diff --cached --quiet; then
  git commit -m "BUBKA-003: format and validate grouped release package"
fi
git push origin HEAD:refs/heads/phase/03-installation-updates
echo "BUBKA PHASE 03 BATCH VALIDATED AND PUSHED"
