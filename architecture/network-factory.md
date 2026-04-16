# Network Factory

## PXE Pipeline Overview

```
Client PXE boots
  → Kea DHCP (client-class detection)
  → TFTP: undionly.kpxe (native PXE) or autoexec.ipxe (iPXE)
  → autoexec.ipxe routes by MAC
  → Discovery mode or Install mode
  → FCOS assets from System-1:80
```

## Kea DHCP Client-Class Detection

| Client Type | Detected By | File Served |
|---|---|---|
| Native PXE | `PXEClient` in option 60 | `undionly.kpxe` via TFTP |
| iPXE | `iPXE` in user-class | `autoexec.ipxe` via TFTP |

## autoexec.ipxe Routing

- Routes by MAC address to one of two modes.
- Unknown MACs fall through to a safe default (chain or shell).

## Discovery Mode

- Boots entirely in RAM — no disk writes.
- Static Ignition contains: SSH authorized key, hostname only.
- No bridge config, no prep-machine service.
- Purpose: SSH in and run `lsblk`, `ip link` to capture real hardware names.

## Install Mode

- Requires verified hardware names from discovery.
- Key kernel args:
  - `coreos.inst.install_dev=/dev/sda` (verified disk name)
  - `coreos.inst.ignition_url=http://10.0.0.1/ignition/install.ign`
- Ignition is flattened static JSON (no URL references).
- Ignition includes: insecure registry config for `10.0.0.1:5000`, prep-machine.service.

## prep-machine.service

Runs after first boot on installed disk:

1. `bootc switch registry.example.com/hypervisor-image:latest` — pulls immutable OS image from `10.0.0.1:5000`.
2. System reboots into the persistent bootc-managed OS.

## FCOS Asset Hosting

- All FCOS kernel, initrd, and rootfs files hosted on System-1 at port 80.
- No external internet required during install.
- Path example: `http://10.0.0.1/fcos/fedora-coreos-*.x86_64.metal.raw.xz`
