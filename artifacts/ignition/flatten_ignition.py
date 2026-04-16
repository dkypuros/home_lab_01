#!/usr/bin/env python3
"""
Flatten all Ignition PHP fragments into a single static JSON file.
Run on System-1 where the jasonn3-ignition-lab container serves the fragments.

Usage: python3 flatten_ignition.py
Output: /tmp/jasonn3-ignition-working/ignition/src/fcos/system-2-final.ign
"""
import json, urllib.request, urllib.parse, sys

base_url = "http://127.0.0.1/fcos"
node = "system-2"

# Fetch the top-level merge config
top = json.loads(urllib.request.urlopen(f"{base_url}/ignition.php?node={node}").read())
sources = top["ignition"]["config"]["merge"]

final = {
    "ignition": {"version": "3.4.0"},
    "passwd": {"users": []},
    "storage": {"disks": [], "filesystems": [], "files": []},
    "systemd": {"units": []}
}

users_by_name = {}

for src in sources:
    url = src["source"]
    try:
        frag = json.loads(urllib.request.urlopen(url).read())
    except Exception as e:
        print(f"ERROR fetching {url}: {e}", file=sys.stderr)
        sys.exit(1)

    for user in frag.get("passwd", {}).get("users", []):
        name = user["name"]
        if name not in users_by_name:
            users_by_name[name] = user
        else:
            existing = users_by_name[name]
            for key in user:
                if key == "sshAuthorizedKeys":
                    existing.setdefault("sshAuthorizedKeys", []).extend(user["sshAuthorizedKeys"])
                else:
                    existing[key] = user[key]

    for f in frag.get("storage", {}).get("files", []):
        final["storage"]["files"].append(f)
    for d in frag.get("storage", {}).get("disks", []):
        final["storage"]["disks"].append(d)
    for fs in frag.get("storage", {}).get("filesystems", []):
        final["storage"]["filesystems"].append(fs)
    for u in frag.get("systemd", {}).get("units", []):
        final["systemd"]["units"].append(u)

final["passwd"]["users"] = list(users_by_name.values())

# Add insecure registry config (critical for bootc switch!)
registry_conf = '[[registry]]\nlocation = "10.0.0.1:5000"\ninsecure = true\n'
final["storage"]["files"].append({
    "path": "/etc/containers/registries.conf.d/010-lab-registry.conf",
    "mode": 420,
    "overwrite": True,
    "contents": {"source": "data:," + urllib.parse.quote(registry_conf, safe="")}
})

# Clean empties
for key in ["disks", "filesystems", "files"]:
    if not final["storage"][key]:
        del final["storage"][key]
if not final["storage"]:
    del final["storage"]
if not final["passwd"]["users"]:
    del final["passwd"]
if not final["systemd"]["units"]:
    del final["systemd"]

outpath = "/tmp/jasonn3-ignition-working/ignition/src/fcos/system-2-final.ign"
with open(outpath, "w") as f:
    json.dump(final, f, indent=2)

print(f"Written to {outpath}")
print(f"  Users: {len(final.get('passwd', {}).get('users', []))}")
print(f"  Files: {len(final.get('storage', {}).get('files', []))}")
print(f"  Disks: {len(final.get('storage', {}).get('disks', []))}")
print(f"  Units: {len(final.get('systemd', {}).get('units', []))}")
