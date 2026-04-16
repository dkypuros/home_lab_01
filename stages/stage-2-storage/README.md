# Stage 2 — Storage

## Goal

Partition and mount additional disks on System-2, register them as libvirt storage pools, and verify with a smoketest VM.

## Disks

| Device | Pool Name | Filesystem |
|---|---|---|
| /dev/sdb | ssd-a | XFS |
| /dev/sdc | ssd-b | XFS |

## Partition and Format

```bash
parted /dev/sdb mklabel gpt mkpart primary xfs 0% 100%
mkfs.xfs /dev/sdb1

parted /dev/sdc mklabel gpt mkpart primary xfs 0% 100%
mkfs.xfs /dev/sdc1
```

## systemd Mount Units

Mount units must use escaped paths. Hyphens in mount paths escape as `\x2d`.

| Mount Point | Unit Name |
|---|---|
| /var/lib/libvirt/ssd-a | `var-lib-libvirt-ssd\x2da.mount` |
| /var/lib/libvirt/ssd-b | `var-lib-libvirt-ssd\x2db.mount` |

Example unit (`/etc/systemd/system/var-lib-libvirt-ssd\x2da.mount`):

```ini
[Unit]
Description=Mount ssd-a for libvirt

[Mount]
What=/dev/sdb1
Where=/var/lib/libvirt/ssd-a
Type=xfs
Options=defaults

[Install]
WantedBy=local-fs.target
```

```bash
systemctl daemon-reload
systemctl enable --now var-lib-libvirt-ssd\x2da.mount
systemctl enable --now var-lib-libvirt-ssd\x2db.mount
```

## libvirt Storage Pools

```bash
virsh pool-define-as ssd-a dir - - - - /var/lib/libvirt/ssd-a
virsh pool-build ssd-a
virsh pool-start ssd-a
virsh pool-autostart ssd-a

virsh pool-define-as ssd-b dir - - - - /var/lib/libvirt/ssd-b
virsh pool-build ssd-b
virsh pool-start ssd-b
virsh pool-autostart ssd-b
```

## Smoketest VM

- Image: cirros (small cloud image)
- Network: br0
- DHCP: Kea assigns address from main pool
- Validation:

```bash
virsh console smoketest
# Inside VM:
ping 10.0.0.1   # reaches System-1
```

## Validation Checklist

| Check | Expected |
|---|---|
| `df -h /var/lib/libvirt/ssd-a` | mounted, XFS |
| `df -h /var/lib/libvirt/ssd-b` | mounted, XFS |
| `virsh pool-list --all` | ssd-a, ssd-b active |
| smoketest VM ping | success |
