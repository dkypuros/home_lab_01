# Stage 1 — KVM Foundation

## Goal

Install a bootc-managed hypervisor OS on a bare-metal machine with libvirt, br0, and container registry access.

## Phases

### Phase 0 — Hub Alignment (System-1)

- Kea DHCP: client-class rules for PXE vs iPXE, static reservations for target MAC.
- BIND: A record for target hostname.
- iPXE: autoexec.ipxe routes target MAC to discovery mode.
- Registry: `10.0.0.1:5000` reachable and hypervisor image pushed.

### Phase 1 — Discovery Probe

- Boot target into RAM via discovery Ignition.
- SSH in, run `lsblk` and `ip link show`.
- Record disk device and NIC name in inventory.
- See `architecture/discovery-before-destruction.md`.

### Phase 2 — Build Hypervisor Image

- Containerfile based on Fedora CoreOS or RHEL bootc base.
- Key packages: `libvirt`, `qemu-kvm`, `bridge-utils`, `nfs-utils`.
- `nfs-utils` swap: replace `nfs-utils` meta-package if it conflicts with `nfs-utils-coreos`.
- `TMPDIR` fix: set `TMPDIR=/var/tmp` during image build to avoid tmpfs overflow.
- Push to `10.0.0.1:5000/hypervisor:latest`.

### Phase 3 — Flatten Ignition and Pour

- Ignition (install mode) must be fully static JSON — no URL references to other Ignition files.
- Required contents:
  - SSH authorized key
  - Insecure registry config for `10.0.0.1:5000`
  - `prep-machine.service` (runs `bootc switch` on first boot)
  - Hostname unit
- Kernel args: `coreos.inst.install_dev=/dev/sda` (use verified disk name).
- Update autoexec.ipxe to route target MAC to install mode, then reboot target.

### Phase 4 — Validation

| Check | Expected |
|---|---|
| `hostname` | `system-2` |
| `ip link show br0` | `UP` |
| `systemctl is-active libvirtd` | `active` |
| `podman pull 10.0.0.1:5000/test` | succeeds |
| `bootc status` | shows booted image |
