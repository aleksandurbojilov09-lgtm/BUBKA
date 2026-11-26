#!/usr/bin/env bash
set -Eeuo pipefail
umask 077
input=${1:?Unsigned APK path required}
output=${2:?Signed APK path required}
: "${BUBKA_KEYSTORE_BASE64:?Missing signing key}"
: "${BUBKA_KEYSTORE_PASSWORD:?Missing signing password}"
[[ ! -e "$output" ]]
tools="${ANDROID_HOME:?ANDROID_HOME not set}/build-tools/36.0.0"
stage=$(mktemp -d)
trap 'rm -rf -- "$stage"' EXIT
bash scripts/verify-release-apk.sh "$input" unsigned
printf '%s' "$BUBKA_KEYSTORE_BASE64" | base64 --decode > "$stage/key.p12"
unset BUBKA_KEYSTORE_BASE64
"$tools/zipalign" -P 16 -f 4 "$input" "$stage/aligned.apk"
"$tools/apksigner" sign --ks "$stage/key.p12" --ks-type PKCS12 \
  --ks-key-alias bubka-release --ks-pass env:BUBKA_KEYSTORE_PASSWORD \
  --key-pass env:BUBKA_KEYSTORE_PASSWORD --out "$stage/signed.apk" "$stage/aligned.apk"
unset BUBKA_KEYSTORE_PASSWORD
"$tools/zipalign" -c -P 16 4 "$stage/signed.apk"
bash scripts/verify-release-apk.sh "$stage/signed.apk" signed
mv -- "$stage/signed.apk" "$output"
