# nuc — Discord Gateway

## Key Facts
| Field | Value |
|-------|-------|
| Role | Discord gateway / OOB access / nginx proxy |
| OS | Fedora 43 Server |
| CPU | Intel NUC Celeron J4005 |
| RAM | 7.3 GB |
| Disk | 15G root |
| State | Active |

## Network
| Interface | IP / Address | Purpose |
|-----------|-------------|---------|
| WiFi | 192.168.86.47 | Home network |
| Lab | 10.0.0.143 | Lab network |
| Tailscale | oob-nuc.tailfc4ba9.ts.net | Remote / OOB access |

## Access
| Method | Details |
|--------|---------|
| SSH | `ssh student@nuc` |
| Cockpit | http://192.168.86.47:9090 |

## Services
| Service | Detail |
|---------|--------|
| clawhip | Rust Discord bot — systemd, runs as root |
| OpenClaw | Node.js subagent runtime |
| Sandbox mode | non-main — Podman containers |
| nginx | Reverse proxy for GitLab |
| Claude Code | v2.1.98 installed (fallback) |

## Notes
- GitLab exposed via nginx at https://oob-nuc.tailfc4ba9.ts.net:8444
- clawhip runs as root via systemd unit
- OpenClaw handles subagent dispatch in Podman sandbox containers
