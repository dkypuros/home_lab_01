# v3 — Golden Lab 03

## Date

2026-04-09 to present

## Status

Current state. Full pipeline operational.

## Stack

| Layer | Component | Detail |
|---|---|---|
| Hub | System-1 (Fedora 43) | Kea, BIND, iPXE, registry, FCOS assets |
| Hypervisor | System-2 (bootc) | libvirt, br0, Kubernetes bubble host |
| K8s cluster | bubble-a | 1 control plane + 2 workers, Cilium CNI |
| Workstations | claude-ws, Guacamole VM | AI orchestration, browser-based access |
| Orchestration | Claude Code (multi-instance) | Mac + claude-ws + remote sessions |

## Full Pipeline

```
PXE boot → Kea client-class → iPXE autoexec
  → discovery (RAM boot, capture hardware)
  → install (FCOS + static Ignition)
  → prep-machine.service (bootc switch)
  → persistent immutable hypervisor OS
  → libvirt + bubble-a network
  → K8s bootstrap (kubeadm + Cilium)
```

## Key Milestones

| Date | Event |
|---|---|
| 2026-04-09 | Fedora pivot complete on System-1 |
| 2026-04-09 | System-2 hypervisor installed via bootc pipeline |
| 2026-04-10 | Storage pools ssd-a, ssd-b operational |
| 2026-04-11 | bubble-a network and bind-kea-a VM running |
| 2026-04-12 | K8s cluster bootstrapped, all nodes Ready |
| 2026-04-13 | Cilium v1.19.1 installed |
| 2026-04-14 | Dashboard + sample workloads deployed |
| 2026-04-16 | Documentation repo structured |

## Multi-AI Orchestration

- Mac Claude Code: architecture, documentation, orchestration.
- claude-ws Claude Code: remote execution, file writes, SSH ops.
- Cross-instance context via `~/.omc/state/` injection (see `guides/orchestration-brain-surgery.md`).

## What Makes This "Golden"

- Fully reproducible: `guides/rebuild-from-scratch.md` covers complete rebuild.
- Immutable OS: bootc-managed hypervisor, no config drift.
- Empirical methodology: discovery before destruction prevents hardware name errors.
- Bubble isolation: clusters independent, host stays clean.
- All deviations and gotchas documented in `iterations/` and `guides/`.
