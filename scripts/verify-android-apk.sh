#!/usr/bin/env bash
set -Eeuo pipefail
apk=${1:?APK path required}
sdk=${ANDROID_HOME:?ANDROID_HOME not set}
tools="$sdk/build-tools/36.0.0"
[[ -s "$apk" ]]
unzip -tq "$apk"
python3 - "$apk" <<'PY_APK'
import sys, zipfile
with zipfile.ZipFile(sys.argv[1]) as archive:
    names = set(archive.namelist())
    for name in ['AndroidManifest.xml', 'classes.dex', 'lib/arm64-v8a/libflutter.so', 'assets/flutter_assets/kernel_blob.bin']:
        if name not in names:
            raise SystemExit('Missing APK entry: ' + name)
print('APK structure OK')
PY_APK
badging=$("$tools/aapt" dump badging "$apk")
printf '%s\n' "$badging"
grep -Eq "^package: name='io\.github\.aleksandurbojilov09\.garage' versionCode='1' versionName='0\.0\.1'" <<< "$badging"
grep -q '^application-debuggable' <<< "$badging"
cert=$("$tools/apksigner" verify --verbose --print-certs "$apk")
printf '%s\n' "$cert"
grep -q 'CN=Android Debug' <<< "$cert"
sha256sum "$apk"
stat -c 'APK bytes: %s' "$apk"
echo 'BUBKA_APK_VERIFIED_DEBUG'
