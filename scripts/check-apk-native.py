"""Check required Flutter libraries and 64-bit ELF PT_LOAD page alignment."""
import struct
import sys
import zipfile

with zipfile.ZipFile(sys.argv[1]) as archive:
    names = set(archive.namelist())
    for abi in ("armeabi-v7a", "arm64-v8a", "x86_64"):
        for lib in ("libapp.so", "libflutter.so"):
            if f"lib/{abi}/{lib}" not in names:
                raise SystemExit(f"Missing required native library: {abi}/{lib}")
    for name in sorted(names):
        if not name.startswith(("lib/arm64-v8a/", "lib/x86_64/")) or not name.endswith(".so"):
            continue
        data = archive.read(name)
        if data[:6] != b"\x7fELF\x02\x01":
            raise SystemExit(f"Invalid 64-bit little-endian ELF: {name}")
        phoff = struct.unpack_from("<Q", data, 32)[0]
        entsize, count = struct.unpack_from("<HH", data, 54)
        if entsize < 56 or phoff + count * entsize > len(data):
            raise SystemExit(f"Invalid program headers: {name}")
        loads = 0
        for i in range(count):
            kind, _, offset, vaddr, _, _, _, align = struct.unpack_from("<IIQQQQQQ", data, phoff + i * entsize)
            if kind == 1:
                loads += 1
                if align < 16384 or (offset - vaddr) % 16384:
                    raise SystemExit(f"16 KiB ELF alignment failure: {name}, alignment={align}")
        if not loads:
            raise SystemExit(f"No loadable segments: {name}")
        print(f"ELF 16 KiB OK: {name}")
