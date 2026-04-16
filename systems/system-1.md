# system-1 — Hub

## Key Facts
| Field | Value |
|-------|-------|
| Role | Hub / gateway / services host |
| OS | Fedora 43 Server |
| CPU | AMD Ryzen 5 3600 |
| RAM | 62 GB |
| Disk | 238G SSD |
| State | Active |

## Network
| Interface | IP / Address | Purpose |
|-----------|-------------|---------|
| enp8s0f0 | 192.168.86.20 | Home WiFi (upstream) |
| enp8s0f1 | 10.0.0.1 | Lab network (lab-facing) |
| Tailscale | system-1-2.tailfc4ba9.ts.net | Remote access |

## Storage Layout
| Mount / Device | Size | Notes |
|---------------|------|-------|
| / (root) | 15G | Tight — monitor usage |
| /var/lib/libvirt/images | 100G | VM image storage |
| Unallocated LVM | 121G | Available for expansion |

## Access
| Method | Details |
|--------|---------|
| SSH | `ssh student@sys1` — key: `id_ed25519_hypervisor` |
| Cockpit | http://192.168.86.20:9090 |

## Services
| Service | Port / Detail |
|---------|--------------|
| Kea DHCP | Lab DHCP server |
| BIND DNS | Lab DNS resolver |
| TFTP | PXE boot file serving |
| iPXE | Network boot chain |
| Apache/PHP | Port 80 |
| OCI Registry | 10.0.0.1:5000 |
| httpd | Port 8090 |

## Hosted VMs
- `ubuntu-gitlab-src-1`
- `claude-workstation`
