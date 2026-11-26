#!/usr/bin/env bash
set -Eeuo pipefail
apk=${1:?APK path required}
mode=${2:-signed}
tools="${ANDROID_HOME:?ANDROID_HOME not set}/build-tools/36.0.0"
[[ "$mode" == signed || "$mode" == unsigned ]]
[[ -s "$apk" ]]
unzip -tq "$apk"
python3 - "$apk" <<'PY_APK'
import sys, zipfile
with zipfile.ZipFile(sys.argv[1]) as archive:
    names = set(archive.namelist())
    for name in ['AndroidManifest.xml', 'classes.dex', 'lib/arm64-v8a/libflutter.so', 'lib/arm64-v8a/libapp.so', 'lib/armeabi-v7a/libapp.so', 'lib/x86_64/libapp.so']:
        if name not in names:
            raise SystemExit('Missing release APK entry: ' + name)
    if 'assets/flutter_assets/kernel_blob.bin' in names:
        raise SystemExit('Unexpected debug kernel')
PY_APK
python3 scripts/check-apk-native.py "$apk"
badging=$("$tools/aapt" dump badging "$apk")
version=$(python3 scripts/version.py version)
build=$(python3 scripts/version.py build)
expected="package: name='io.github.aleksandurbojilov09.garage' versionCode='$build' versionName='$version'"
package_line=$(grep '^package: ' <<< "$badging")
[[ "$package_line" == "$expected" || "$package_line" == "$expected "* ]]
if grep -q '^application-debuggable' <<< "$badging"; then
  echo 'Debuggable APK rejected' >&2
  exit 1
fi
if [[ "$mode" == signed ]]; then
  cert=$("$tools/apksigner" verify --verbose --print-certs "$apk")
  printf '%s\n' "$cert"
  expected_cert=$(tr -d '[:space:]' < config/android-release-cert.sha256)
  actual_cert=$(sed -n 's/^Signer #1 certificate SHA-256 digest: //p' <<< "$cert" | tr '[:upper:]' '[:lower:]')
  [[ "$actual_cert" == "$expected_cert" ]]
  [[ $(grep -c '^Signer #[0-9][0-9]* certificate SHA-256 digest:' <<< "$cert") == 1 ]]
else
  python3 scripts/check-unsigned-apk.py "$apk"
  if result=$("$tools/apksigner" verify "$apk" 2>&1); then
    echo 'Expected unsigned release APK' >&2
    exit 1
  fi
  printf '%s\n' "$result"
  # Require an explicit missing-signature diagnosis; do not accept arbitrary verifier failures.
  if ! grep -Eqi 'missing META-INF/MANIFEST\.MF|no (JAR |APK )?signatures?|not signed|no signers' <<< "$result"; then
    echo 'Unexpected APK verifier failure' >&2
    exit 1
  fi
fi
sha256sum "$apk"
stat -c 'APK bytes: %s' "$apk"
echo "BUBKA_RELEASE_APK_VERIFIED_$mode"
