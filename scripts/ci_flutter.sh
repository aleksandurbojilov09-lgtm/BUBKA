#!/usr/bin/env bash
set -Eeuo pipefail
version=3.50.1
revision=ae9b586f34a8443573f82ef57c3bf914a908cbf7
cache="$RUNNER_TEMP/bubka-sdk-archive"
mkdir -p "$cache"
case "$(uname -s):$(uname -m)" in
  Linux:x86_64)
    platform=linux; archive=stable/linux/flutter_linux_3.50.1-stable.tar.xz
    digest=4ad17fc8462fbcef2ba19ff4a78c0a16b7147fde1add8578e267ea62cdb92678
    ;;
  Darwin:arm64)
    platform=macos; archive=stable/macos/flutter_macos_arm64_3.50.1-stable.zip
    curl -fL --retry 3 -o "$RUNNER_TEMP/releases_macos.json" https://storage.googleapis.com/flutter_infra_release/releases/releases_macos.json
    digest=$(python3 - "$RUNNER_TEMP/releases_macos.json" "$archive" "$revision" <<'PY'
import json,re,sys
from pathlib import Path
r=[x for x in json.loads(Path(sys.argv[1]).read_text())['releases'] if x.get('channel')=='stable' and x.get('version')=='3.50.1' and x.get('archive')==sys.argv[2] and x.get('hash')==sys.argv[3]]
assert len(r)==1 and re.fullmatch('[a-f0-9]{64}',r[0]['sha256'])
print(r[0]['sha256'])
PY
)
    ;;
  *) echo 'Unexpected runner'; exit 1;;
esac
file="$cache/${archive##*/}"
verify() { if [[ "$platform" == linux ]]; then printf '%s  %s\n' "$digest" "$file" | sha256sum -c -; else printf '%s  %s\n' "$digest" "$file" | shasum -a 256 -c -; fi; }
if [[ ! -f "$file" ]]; then curl -fL --retry 3 -o "$file" "https://storage.googleapis.com/flutter_infra_release/releases/$archive"; fi
verify
if [[ "$platform" == linux ]]; then tar -xJf "$file" -C "$RUNNER_TEMP"; else unzip -q "$file" -d "$RUNNER_TEMP"; fi
export PATH="$RUNNER_TEMP/flutter/bin:$PATH"
flutter --disable-analytics
flutter --version --machine > "$RUNNER_TEMP/bubka-flutter-version.json"
python3 - "$RUNNER_TEMP/bubka-flutter-version.json" "$version" "$revision" <<'PY'
import json,sys
from pathlib import Path
v=json.loads(Path(sys.argv[1]).read_text()); assert v['frameworkVersion']==sys.argv[2] and v['frameworkRevision']==sys.argv[3] and v['dartSdkVersion'].startswith('3.14.0'),v
PY
echo "$RUNNER_TEMP/flutter/bin" >> "$GITHUB_PATH"
