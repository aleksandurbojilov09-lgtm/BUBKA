#!/usr/bin/env bash
set -Eeuo pipefail
cd "$(git rev-parse --show-toplevel)"
command -v flutter
: "${ANDROID_HOME:?Android SDK environment missing}"
git diff --exit-code -- pubspec.lock
flutter pub get --enforce-lockfile
registrant=android/app/src/main/java/io/flutter/plugins/GeneratedPluginRegistrant.java
check_registrant() {
  test -s "$registrant"
  if grep -q 'dev.flutter.plugins.integration_test' "$registrant"; then
    echo 'STOP: dev-only integration_test in release registrant' >&2
    return 1
  fi
  git diff --exit-code -- pubspec.lock
}
# Flutter #169336: regenerate release configuration before invoking Gradle.
flutter build apk --release --config-only
check_registrant
echo BUBKA_RELEASE_REGISTRANT_OK
flutter build apk --release
check_registrant
bash scripts/verify-release-apk.sh build/app/outputs/flutter-apk/app-release.apk unsigned
echo BUBKA_LOCAL_ANDROID_RELEASE_OK
