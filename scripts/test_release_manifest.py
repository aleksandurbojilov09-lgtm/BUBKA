import hashlib
import json
from pathlib import Path
import subprocess
import tempfile

version = subprocess.check_output(["python3", "scripts/version.py", "version"], text=True).strip()
build = int(subprocess.check_output(["python3", "scripts/version.py", "build"], text=True))
with tempfile.TemporaryDirectory() as temp:
    directory = Path(temp)
    filenames = [f"BUBKA-{version}-{build}.apk", f"BUBKA-{version}-{build}-unsigned.ipa"]
    for name in filenames:
        (directory / name).write_bytes(name.encode())
    subprocess.run(["python3", "scripts/create-update-manifest.py", temp, "testing"], check=True)
    manifest = json.loads((directory / "update-manifest.json").read_text())
    assert manifest["tag"] == f"v{version}" and manifest["channel"] == "testing"
    assert [a["filename"] for a in manifest["assets"]] == filenames
    for asset in manifest["assets"]:
        name = asset["filename"]
        assert asset["download_url"] == f"https://github.com/aleksandurbojilov09-lgtm/BUBKA/releases/download/v{version}/{name}"
        assert asset["size_bytes"] == (directory / name).stat().st_size
        assert asset["sha256"] == hashlib.sha256((directory / name).read_bytes()).hexdigest()
    subprocess.run(["sha256sum", "-c", "SHA256SUMS.txt"], cwd=directory, check=True)
print("Release manifest names, URLs, sizes and checksums verified")
