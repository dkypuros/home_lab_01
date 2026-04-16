# guacamole-vm — Browser Desktop VM

## Key Facts
| Field | Value |
|-------|-------|
| Role | Browser-based remote desktop gateway |
| Host | system-1 (macvtap) |
| OS | Fedora 43 Cloud |
| State | Active |

## Network
| Interface | IP / Address |
|-----------|-------------|
| Tailscale | guacamole-vm.tailfc4ba9.ts.net |

## Access
| Method | Details |
|--------|---------|
| Web UI | http://guacamole-vm.tailfc4ba9.ts.net:8080/guacamole/ |
| Login | student / student |

## Software
| Component | Detail |
|-----------|--------|
| Apache Guacamole | WAR — migrated with Jakarta migration tool for Tomcat 10.1 |
| guacd | Compiled from source, v1.5.5 |
| Java | 21 |

## Configured Connections
| Connection | Protocol | Target |
|-----------|----------|--------|
| Claude Workstation Desktop | VNC | claude-workstation:5901 |
| Claude Workstation SSH | SSH | claude-workstation |
| Local Desktop | — | Local display |

## Notes
- macvtap NIC — directly on home LAN
- Guacamole WAR required Jakarta namespace migration to run on Tomcat 10.1
- guacd built from source at v1.5.5 for compatibility
