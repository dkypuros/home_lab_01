# gitlab-vm — GitLab VM

## Key Facts
| Field | Value |
|-------|-------|
| Role | Self-hosted GitLab source control |
| Host | system-1 (macvtap) |
| OS | Ubuntu 24.04 |
| IP | 192.168.86.48 |
| GitLab | 18.10.3-ee (self-compiled) |
| Tailscale | None |
| State | Active |

## Access
| Method | Details |
|--------|---------|
| Web UI | https://oob-nuc.tailfc4ba9.ts.net:8444 (via NUC nginx proxy) |
| SSH | `ssh ubuntu@gitlab-vm` |

## Network Notes
- macvtap NIC — directly on home LAN at 192.168.86.48
- system-1 cannot reach gitlab-vm due to macvtap host limitation
- SSH from Mac directly: `ssh ubuntu@192.168.86.48`
- Web traffic proxied through NUC nginx reverse proxy

## Software
| Component | Detail |
|-----------|--------|
| GitLab | 18.10.3-ee, self-compiled |
| Proxy | nginx on NUC (oob-nuc) — port 8444 |

## Notes
- macvtap VMs on system-1 are reachable from other hosts on the LAN but not from system-1 itself
- Use Mac or NUC as jump point for direct access
