#!/usr/bin/env bash
set -Eeuo pipefail
cd "$(git rev-parse --show-toplevel)"
command -v flutter
: "${ANDROID_HOME:?Android SDK environment missing}"
# Flutter issue #169336: --no-pub may retain dev-only plugin registration.
flutter pub get --enforce-lockfile
flutter build apk --release
git diff --exit-code -- pubspec.lock
registrant=android/app/src/main/java/io/flutter/plugins/GeneratedPluginRegistrant.java
test -s "$registrant"
if grep -q 'dev.flutter.plugins.integration_test' "$registrant"; then
  echo "Release registrant still contains integration_test" >&2
  exit 1
fi
bash scripts/verify-release-apk.sh build/app/outputs/flutter-apk/app-release.apk unsigned
