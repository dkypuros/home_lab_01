# system-2 — KVM Hypervisor

## Key Facts
| Field | Value |
|-------|-------|
| Role | KVM hypervisor |
| OS | Fedora CoreOS 43 (bootc) |
| CPUs | 12 |
| RAM | 63 GB |
| State | Active |

## Storage
| Device | Size | Purpose |
|--------|------|---------|
| /dev/sda | 223G | OS disk |
| /dev/sdb | 954G | ssd-a |
| /dev/sdc | 954G | ssd-b |

## Network
| Interface | Detail |
|-----------|--------|
| enp4s0 | Bridged as br0, MAC 74:56:3c:08:60:bd |
| Lab IP | 10.0.0.102 |
| Tailscale | None |

## Access
| Method | Details |
|--------|---------|
| SSH | `ssh core@sys2` — ProxyJump through sys1 required |
| Cockpit | http://10.0.0.102:9090 (admin/admin) — tunnel required |

## Image
- Source: `10.0.0.1:5000/hypervisor_node:latest`

## Hosted Network — bubble-a (10.2.0.0/24)
| VM | Role |
|----|------|
| bind-kea-a | DNS + DHCP for bubble-a |
| k8s-cp-1 | Kubernetes control plane |
| k8s-worker-1 | Kubernetes worker |
| k8s-worker-2 | Kubernetes worker |

## Kubernetes
| Component | Version |
|-----------|---------|
| Kubernetes | v1.32.13 |
| Cilium CNI | v1.19.1 |

## Notes
- No direct external access — all SSH via ProxyJump through sys1
- Cockpit requires SSH tunnel: `ssh -L 9090:10.0.0.102:9090 student@sys1`
- Smart plug available for power control
