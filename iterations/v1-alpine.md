# v1 — Alpine Linux

## Period

Pre-2026-04-09

## Stack

| Component | Tool |
|---|---|
| OS (System-1) | Alpine Linux |
| DHCP/DNS | dnsmasq (combined) |
| PXE | dnsmasq built-in |
| Container runtime | Docker |
| Image management | None (manual) |
| OS lifecycle | Mutable (apk) |

## What Worked

- Basic PXE boot pipeline functional.
- dnsmasq handled DHCP and DNS from a single config file.
- Low resource usage on System-1.
- Sufficient for simple VM provisioning.

## Limitations

| Gap | Impact |
|---|---|
| No immutable infrastructure | OS drift over time, hard to reproduce |
| No container image pipeline | Hypervisor config not version-controlled |
| No bootc | Can't switch OS images atomically |
| dnsmasq DHCP+DNS coupling | Hard to add client-class PXE routing |
| No local registry | All images pulled from internet |
| No Ignition integration | Machine config managed manually |

## Pivot Decision

2026-04-09: Rebuilt System-1 on Fedora 43 Server. Rationale: need immutable infrastructure, bootc pipeline, and Kea client-class PXE routing for the network factory pattern.

See `iterations/v2-fedora-pivot.md` for the rebuild details.
