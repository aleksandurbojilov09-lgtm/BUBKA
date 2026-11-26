"""Read-only resource diagnostics. Never print process arguments or environment secrets."""
import json
import os
from pathlib import Path
import re
import sys

def unescape(value):
    return re.sub(r"\\([0-7]{3})", lambda m: chr(int(m[1], 8)), value)

meminfo = Path("/proc/meminfo").read_text()
total = int(re.search(r"^MemTotal:\s+(\d+)", meminfo, re.M)[1]) * 1024
available = int(re.search(r"^MemAvailable:\s+(\d+)", meminfo, re.M)[1]) * 1024
limits = [total]
groups = []
current = next((line.split(":", 2)[2] for line in Path("/proc/self/cgroup").read_text().splitlines() if line.startswith("0::")), None)
if current is not None:
    for line in Path("/proc/self/mountinfo").read_text().splitlines():
        left, right = line.split(" - ", 1)
        if right.split()[0] != "cgroup2":
            continue
        fields = left.split()
        root, mount = unescape(fields[3]), Path(unescape(fields[4]))
        if root == "/":
            candidate = mount / current.lstrip("/")
        elif current == root or current.startswith(root.rstrip("/") + "/"):
            candidate = mount / current[len(root):].lstrip("/")
        else:
            candidate = mount
        if not (candidate / "memory.max").is_file():
            continue
        for folder in (candidate, *candidate.parents):
            if not folder.is_relative_to(mount):
                break
            row = {"path": str(folder)}
            for key in ("memory.max", "memory.current", "memory.peak", "memory.events", "memory.events.local", "memory.swap.max", "memory.swap.current"):
                try:
                    value = (folder / key).read_text().strip()
                except OSError:
                    continue
                if key.startswith("memory.events"):
                    row[key] = {k: int(v) for k, v in (l.split() for l in value.splitlines())}
                else:
                    row[key] = value
                if key == "memory.max" and value.isdigit():
                    limits.append(int(value))
            groups.append(row)
        break
gradle_home = Path(os.environ.get("GRADLE_USER_HOME", str(Path.home() / ".gradle")))
overrides = []
p = gradle_home / "gradle.properties"
if p.exists():
    for line in p.read_text().splitlines():
        m = re.match(r"\s*(org\.gradle\.(?:jvmargs|workers\.max|parallel)|kotlin\.daemon\.jvmargs)\s*[:=]", line)
        if m:
            overrides.append(m[1])
cpu = len(os.sched_getaffinity(0))
print(json.dumps({"ram_total_bytes": total, "ram_available_bytes": available, "effective_memory_upper_bound_bytes": min(limits), "cpu_affinity_count": cpu, "cgroup_v2_observed": bool(groups), "cgroups": groups, "gradle_user_override_names": overrides}, indent=2))
if "--gate" in sys.argv:
    if not groups or min(limits) < int(6.5 * 1024**3) or cpu < 2 or overrides:
        raise SystemExit("STOP: memory/cgroup/override diagnostics do not support approved 3 GiB profile; review before building")
