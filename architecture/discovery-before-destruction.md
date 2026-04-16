# Discovery Before Destruction

## Methodology

Boot the target machine into RAM first. Capture ground truth hardware identifiers. Only then commit to a destructive install.

## Why It Matters

| Failure Mode | Cause | Prevention |
|---|---|---|
| "Inception" failure | Wrong disk device name in Ignition (e.g., `sdb` instead of `sda`) | Discovery reveals actual device |
| "Sawing off the branch" | Broken bridge config cuts SSH, can't recover remotely | Discovery tests NIC name before committing |
| Silent wipe of wrong disk | Ignition installs to unintended device | Verified name locked before install |

## Act I — Discovery Boot

- autoexec.ipxe routes target MAC to discovery kernel args.
- Ignition: SSH authorized key + hostname only. Nothing else.
- No bridge configuration. No prep-machine service. No disk writes.
- Machine boots entirely in RAM.

## Act I — Capture Hardware

SSH in and run:

```bash
lsblk                   # reveals real disk device name (sda, nvme0n1, etc.)
ip link show            # reveals real NIC name (eno1, enp3s0, etc.)
```

Record both in inventory before proceeding.

## Act II — Destructive Install

- Update autoexec.ipxe to route target MAC to install mode.
- Flatten Ignition with verified `install_dev` and `bridge` NIC name.
- Reboot target — install proceeds with correct hardware names.

## Inventory Record Format

```
hostname:   system-2
disk:       /dev/sda
nic:        enp3s0
date:       2026-04-09
```

## Key Principle

Discovery is read-only. Install is write-once-correct. Never guess hardware names.
