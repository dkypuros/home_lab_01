# v2 — Fedora Pivot

## Date

2026-04-09

## What Changed

Rebuilt System-1 from Alpine Linux to Fedora 43 Server.

## New Stack

| Component | Tool |
|---|---|
| OS (System-1) | Fedora 43 Server |
| DHCP | Kea DHCPv4 |
| DNS | BIND9 |
| PXE | iPXE chainloading via TFTP |
| Container runtime | Podman |
| Local registry | registry:2 container on port 5000 |
| Ignition serving | jasonn3-ignition-lab PHP container |

## Key Additions

- Kea client-class detection: native PXE → `undionly.kpxe`, iPXE → `autoexec.ipxe`
- BIND split from DHCP — each service independently manageable
- iPXE autoexec.ipxe routes by MAC to discovery or install mode
- Local FCOS asset hosting on port 80 — no internet required during installs
- Local registry at `10.0.0.1:5000` for hypervisor image storage

## 11 Deviations Documented During Rebuild

1. dnsmasq removed — replaced entirely by Kea + BIND
2. TFTP server: `tftp-server` package, not dnsmasq built-in
3. iPXE binary: `undionly.kpxe` from `ipxe-bootimgs` package
4. Kea client-class syntax differs from dnsmasq — required separate `boot-file-name` per class
5. BIND zone file required explicit `$TTL` directive
6. Podman socket needed for rootless registry container
7. Registry container required `--restart=always` flag for persistence
8. jasonn3-ignition-lab required PHP-FPM + nginx, not Apache
9. FCOS assets must match exact stream/version used in kernel args
10. firewalld rules needed for ports 69 (TFTP), 80, 5000, 8080
11. SELinux context on TFTP root: `chcon -Rt tftpdir_t /var/lib/tftpboot`

## Outcome

Foundation for the network factory pattern. System-2 hypervisor installation validated end-to-end using this stack.

See `iterations/v3-golden-lab.md` for current state.
