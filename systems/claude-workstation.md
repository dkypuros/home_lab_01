# claude-workstation — Dev VM

## Key Facts
| Field | Value |
|-------|-------|
| Role | Development workstation VM |
| Host | system-1 (macvtap) |
| OS | Fedora 43 Cloud |
| vCPU | 4 |
| RAM | 8 GB |
| Disk | 37 GB |
| State | Active |

## Network
| Interface | IP / Address |
|-----------|-------------|
| Home | 192.168.86.41 |
| Tailscale | claude-workstation.tailfc4ba9.ts.net |

## Access
| Method | Details |
|--------|---------|
| SSH | `ssh student@claude-ws` — password: see .env |
| VNC | Port 5901 (XFCE desktop) |
| Guacamole | Via guacamole-vm — "Claude Workstation Desktop" or "Claude Workstation SSH" |

## Software
| Tool | Version / Detail |
|------|-----------------|
| Claude Code | v2.1.110 |
| Codex | Installed, authenticated |
| Node.js | v24 |
| Desktop | XFCE + VNC on port 5901 |
| Browser | Firefox |

## Notes
- macvtap NIC — directly on home LAN, no NAT
- VNC accessible via Guacamole browser interface
- Primary hands-on dev environment for agentic workloads
