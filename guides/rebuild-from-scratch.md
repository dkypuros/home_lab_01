# Rebuild From Scratch

## Overview

Complete playbook to rebuild System-2 (hypervisor) from bare metal. References artifacts in `artifacts/`.

## Prerequisites

- System-1 running with Kea, BIND, iPXE, and local registry.
- Target MAC address known.
- FCOS assets downloaded to System-1 web root.

## Step 1 — Download FCOS Assets

On System-1:

```bash
FCOS_VER=39.20240101.3.0
curl -L https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/${FCOS_VER}/x86_64/fedora-coreos-${FCOS_VER}-live-kernel-x86_64 \
  -o /var/www/html/fcos/fedora-coreos-${FCOS_VER}-live-kernel-x86_64
# repeat for initrd and rootfs
```

## Step 2 — Build Hypervisor Image

```bash
podman build -t 10.0.0.1:5000/hypervisor:latest -f artifacts/Containerfile .
podman push 10.0.0.1:5000/hypervisor:latest
```

Key gotchas:
- Set `TMPDIR=/var/tmp` to avoid tmpfs overflow during build.
- Use `nfs-utils-coreos` if `nfs-utils` conflicts with base image.

## Step 3 — Set Kea Client Classes

Edit Kea config to add static reservation for target MAC → discovery mode iPXE entry.

Reload Kea:
```bash
systemctl reload kea-dhcp4
```

## Step 4 — Deploy Discovery Ignition

Set autoexec.ipxe to route target MAC to discovery kernel args. Reboot target. SSH in:

```bash
ssh core@<target-ip>
lsblk                 # record disk device
ip link show          # record NIC name
```

## Step 5 — Flatten Ignition

Use `butane` or manual JSON to produce a fully static install Ignition file.

Critical fields:
- `coreos.inst.install_dev=/dev/sda` (use verified disk name — NOT a placeholder)
- `coreos.inst.ignition_url=http://10.0.0.1/ignition/install.ign`
- Insecure registry block for `10.0.0.1:5000`
- `prep-machine.service` unit

Gotchas:
- Use `ignition.config.url` in kernel args for live ISO; use `coreos.inst.ignition_url` for metal install.
- Flatten all Ignition — no nested URL references.
- Bridge NIC name must not be a PLACEHOLDER — use verified name from discovery.

## Step 6 — Pour (Install)

Update autoexec.ipxe to route target MAC to install mode. Reboot target. Wait for install and prep-machine to complete (~5–10 min).

## Step 7 — Setup Storage

See `stages/stage-2-storage/README.md`.

## Step 8 — Build Bubble

See `stages/stage-3-kubernetes-bubble/README.md`.

## Key Gotchas Summary

| Gotcha | Detail |
|---|---|
| iPXE loop | Ensure exit or sanboot after chainload or client loops endlessly |
| Local assets | FCOS kernel/initrd/rootfs must be on System-1, not fetched from internet |
| Flatten Ignition | No URL references in install Ignition |
| Insecure registry | Must be in Ignition before first boot, not added after |
| systemd mount escaping | Hyphens in mount paths → `\x2d` in unit filename |
| `ignition.config.url` vs `coreos.inst.ignition_url` | Use `coreos.inst.ignition_url` for metal install |
| Bridge PLACEHOLDER | Never leave NIC name as placeholder — use discovery-verified name |
