import hashlib
import json
from pathlib import Path
import subprocess
import sys

directory = Path(sys.argv[1])
channel = sys.argv[2]
assert channel in ("testing", "stable")
version = subprocess.check_output(["python3", "scripts/version.py", "version"], text=True).strip()
build = int(subprocess.check_output(["python3", "scripts/version.py", "build"], text=True))
repo = "aleksandurbojilov09-lgtm/BUBKA"
tag = f"v{version}"
assets = []
for platform, filename in (
    ("android", f"BUBKA-{version}-{build}.apk"),
    ("ios", f"BUBKA-{version}-{build}-unsigned.ipa"),
):
    path = directory / filename
    with path.open("rb") as stream:
        digest = hashlib.file_digest(stream, "sha256").hexdigest()
    assert path.stat().st_size > 0
    assets.append(dict(platform=platform, version=version, build_number=build,
                       filename=filename, download_url=f"https://github.com/{repo}/releases/download/{tag}/{filename}",
                       sha256=digest, size_bytes=path.stat().st_size))
(directory / "update-manifest.json").write_text(json.dumps(dict(tag=tag, channel=channel, assets=assets), indent=2)+"\n")
with (directory / "SHA256SUMS.txt").open("w") as output:
    for path in sorted(directory.iterdir()):
        if path.name == "SHA256SUMS.txt":
            continue
        with path.open("rb") as stream:
            print(hashlib.file_digest(stream, "sha256").hexdigest(), " "+path.name, file=output)
