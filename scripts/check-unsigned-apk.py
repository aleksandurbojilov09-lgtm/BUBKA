"""Reject APKs with v1 signatures or a v2/v3 APK Signing Block."""
import struct
import sys
import zipfile

path = sys.argv[1]
with zipfile.ZipFile(path) as apk:
    for name in apk.namelist():
        upper = name.upper()
        if upper.startswith("META-INF/") and upper.endswith((".RSA", ".DSA", ".EC", ".SF")):
            raise SystemExit(f"Unexpected v1 signature: {name}")
with open(path, "rb") as stream:
    stream.seek(0, 2)
    size = stream.tell()
    stream.seek(max(0, size - 65557))
    tail = stream.read()
    end = tail.rfind(b"PK\x05\x06")
    if end < 0 or end + 22 > len(tail):
        raise SystemExit("Missing ZIP end record")
    central = struct.unpack_from("<I", tail, end + 16)[0]
    if central < 24 or central >= size or central == 0xffffffff:
        raise SystemExit("Unsupported ZIP central directory")
    stream.seek(central - 16)
    if stream.read(16) == b"APK Sig Block 42":
        raise SystemExit("Unexpected APK Signing Block")
print("No APK signing block or v1 signature files")
