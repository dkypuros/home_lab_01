# Home Lab 01

A bare-metal home lab built entirely by AI agents. PXE-boots immutable KVM hypervisors, deploys self-contained Kubernetes clusters inside "bubbles," and orchestrates multiple AI coding agents across machines via SSH and Tailscale.

## What's Here

This repo documents the infrastructure, design decisions, and reproducible build artifacts for a multi-system home lab. It's designed to be readable by both humans and AI coding agents (Claude Code, Codex, OMC/OMX harnesses).

## Lab Topology

```
┌─────────────────────────────────────────────────────┐
│  Home Network (192.168.86.0/24)                     │
│                                                     │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐          │
│  │ System-1 │  │  NUC     │  │ Mac      │          │
│  │ (Hub)    │  │ (Discord)│  │ (You)    │          │
│  │ .86.20   │  │ .86.47   │  │ .86.21   │          │
│  └────┬─────┘  └──────────┘  └──────────┘          │
│       │                                              │
│  ┌────┴─── VMs (macvtap) ────────────────┐          │
│  │ GitLab VM (.86.48)                     │          │
│  │ Claude Workstation (.86.41)            │          │
│  │ Guacamole VM (.86.42)                  │          │
│  └────────────────────────────────────────┘          │
└──────────────────────┬──────────────────────────────┘
                       │
              ┌────────┴────────┐
              │ Lab Network     │
              │ (10.0.0.0/24)   │
              │                 │
              │  System-1: .1   │
              │  System-2: .102 │
              │  System-3: .103 │
              └────────┬────────┘
                       │
              ┌────────┴────────────────────┐
              │ System-2 (KVM Hypervisor)    │
              │                              │
              │  ┌── Bubble-A (10.2.0.0/24)──┐
              │  │ bind-kea-a  (.2)  DNS/DHCP │
              │  │ k8s-cp-1    (.10) K8s CP   │
              │  │ k8s-worker-1 (.11) Worker  │
              │  │ k8s-worker-2 (.12) Worker  │
              │  └────────────────────────────┘
              └─────────────────────────────┘
```

## Quick Start

1. **Clone and configure:** Copy `.env.example` to `.env` and fill in your credentials
2. **Read the AI context:** See `CLAUDE.md` for the system prompt any AI agent reads first
3. **Understand the design:** See `architecture/` for why things are built this way
4. **Rebuild from scratch:** See `guides/rebuild-from-scratch.md` for the full playbook
5. **Explore systems:** See `systems/` for per-machine identity files

## Repo Structure

```
├── CLAUDE.md              ← AI reads this first (system prompt)
├── AGENTS.md              ← Agent role definitions
├── .env                   ← Credentials (gitignored)
├── systems/               ← Per-machine identity + access info
├── architecture/          ← Design decisions and principles
├── artifacts/             ← Reproducible build code
│   ├── hypervisor-image/  ← Containerfile + rootfs
│   ├── ignition/          ← iPXE scripts, Ignition configs
│   ├── cloud-init/        ← VM provisioning
│   ├── kea/               ← DHCP config
│   └── scripts/           ← Setup and creation scripts
├── stages/                ← Build progression (1→2→3→4)
├── guides/                ← Operator playbooks
└── iterations/            ← Lab evolution history
```

## Build Stages

| Stage | What | Status |
|-------|------|--------|
| 1 | Bare-metal KVM foundation (PXE → Ignition → bootc) | ✅ |
| 2 | Storage pools (2x 1TB SSDs, libvirt pools) | ✅ |
| 3 | Kubernetes bubble (BIND/Kea VM + 3-node K8s + Cilium) | ✅ |
| 4 | Workloads (dashboard, sample apps) | 🔄 |

## Design Principles

1. **Discovery before Destruction** — Probe hardware empirically before committing
2. **Flatten before Pour** — Static Ignition JSON, no runtime merges
3. **Bubble isolation** — Each hypervisor owns its own DNS/DHCP/K8s
4. **Host stays clean** — Everything in VMs, nothing on bare metal
5. **AI-native** — Built by AI agents, documented for AI agents

## Built With

- Fedora CoreOS + bootc (immutable hypervisor OS)
- KVM/libvirt (virtualization)
- Kubernetes v1.32 + Cilium (container orchestration)
- Kea DHCP + BIND DNS (network services)
- iPXE (network boot)
- Tailscale (remote access)
- Claude Code + Codex (AI agents)
- Cockpit + Guacamole (web management)

## License

This is a personal lab documentation repo. Use it as inspiration for your own builds.
