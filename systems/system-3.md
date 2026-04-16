# system-3 — Not Provisioned

## Key Facts
| Field | Value |
|-------|-------|
| Role | Reserved — intended as kube_node |
| State | NOT provisioned |
| Reserved IP | 10.0.0.103 |
| MAC | 00:13:3b:90:ec:93 |

## Pre-Provisioning Checklist
- [ ] Run discovery act before build
- [ ] Verify hardware via smart plug power cycle
- [ ] Confirm MAC binding in Kea DHCP on system-1
- [ ] Boot via iPXE from system-1 TFTP
- [ ] Assign Kubernetes worker role post-OS install

## Notes
- Smart plug available for remote power control
- No SSH, no Cockpit, no services — system not yet built
- MAC registered for DHCP reservation at 10.0.0.103
- Intended to join existing Kubernetes cluster on system-2 bubble-a network
