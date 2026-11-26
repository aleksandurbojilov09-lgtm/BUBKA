#!/usr/bin/env bash
set -Eeuo pipefail
[[ $(uname -s) == Darwin ]] || { echo 'macOS required'; exit 1; }
app=build/ios/iphoneos/Runner.app
[[ -d "$app" && -f "$app/Info.plist" && ! -e "$app/embedded.mobileprovision" ]]
root=$(pwd)
out="$root/build/bubka-ios-artifacts"
mkdir -p "$out"
stage=$(mktemp -d)
trap 'rm -rf -- "$stage"' EXIT
mkdir "$stage/Payload"
ditto "$app" "$stage/Payload/Runner.app"
# The app must have no distribution/development signing identity. A linker
# ad-hoc signature on an individual Mach-O is not an installable iOS signature.
if signature=$(codesign -dv --verbose=4 "$stage/Payload/Runner.app" 2>&1); then
  printf '%s\n' "$signature"
  if grep -Eq '^Authority=|^TeamIdentifier=[A-Z0-9]{10}$' <<< "$signature"; then
    echo 'STOP: unexpected signing identity' >&2; exit 1
  fi
else
  printf '%s\n' "$signature"
  grep -qi 'not signed at all' <<< "$signature" || exit 1
fi
ipa="$stage/BUBKA-0.0.1-unsigned.ipa"
(cd "$stage" && zip -qry -y "$ipa" Payload)
unzip -tq "$ipa"
python3 - "$ipa" <<'PY_IPA'
import plistlib, sys, zipfile
with zipfile.ZipFile(sys.argv[1]) as z:
    names = set(z.namelist())
    assert all(n.startswith('Payload/') for n in names), 'Unexpected ZIP root'
    base = 'Payload/Runner.app/'
    data = plistlib.loads(z.read(base+'Info.plist'))
    assert data['CFBundleIdentifier'] == 'io.github.aleksandurbojilov09.garage', data
    assert data['CFBundleShortVersionString'] == '0.0.1', data
    assert data['CFBundleVersion'] == '1', data
    assert data['CFBundlePackageType'] == 'APPL', data
    assert base+data['CFBundleExecutable'] in names
    assert base+'Frameworks/App.framework/App' in names
    assert base+'Frameworks/Flutter.framework/Flutter' in names
    assert not any(n.endswith('/embedded.mobileprovision') for n in names)
    print('IPA identity, version and Payload structure OK')
PY_IPA
lipo "$stage/Payload/Runner.app/Runner" -verify_arch arm64
cp "$ipa" "$out/BUBKA-0.0.1-unsigned.ipa"
(cd "$out" && shasum -a 256 BUBKA-0.0.1-unsigned.ipa > SHA256SUMS.txt && cat SHA256SUMS.txt)
stat -f 'IPA bytes: %z' "$out/BUBKA-0.0.1-unsigned.ipa"
echo 'BUBKA_IOS_UNSIGNED_IPA_OK'
