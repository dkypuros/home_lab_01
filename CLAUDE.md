# Home Lab 01

## Identity

This is a bare-metal home lab built with a hands-off network factory. System-1 PXE-boots immutable KVM hypervisors via Ignition and bootc. Each hypervisor hosts a self-contained Kubernetes "bubble" with its own DNS, DHCP, and cluster — nothing runs on the host except KVM.

The lab was built entirely by AI agents (Claude Code, Codex) orchestrating each other across machines via SSH and Tailscale.

## Credentials

Read `.env` for all passwords, IPs, Tailscale FQDNs, and access paths. The `.env` file is gitignored and must exist locally for operational use.

## Systems

| System | Role | Access | Details |
|--------|------|--------|---------|
| System-1 | Hub (DHCP, DNS, PXE, registry) | `ssh sys1` | systems/system-1.md |
| System-2 | KVM hypervisor + K8s bubble | `ssh sys2` | systems/system-2.md |
| NUC | Discord gateway (clawhip/OpenClaw) | `ssh nuc` | systems/nuc.md |
| Claude Workstation | Dev VM (Claude Code + Codex) | `ssh claude-ws` | systems/claude-workstation.md |
| Guacamole VM | Browser desktop via Tailscale | Guacamole URL in .env | systems/guacamole-vm.md |
| GitLab VM | Self-compiled GitLab 18.10.3-ee | URL in .env | systems/gitlab-vm.md |
| System-3 | Reserved, not provisioned | 10.0.0.103 | systems/system-3.md |

## SSH Shortcuts

All systems use the same key (`~/.ssh/id_ed25519_hypervisor`). These shortcuts are configured in `~/.ssh/config`:

```
ssh sys1       → System-1 (via Tailscale)
ssh sys2       → System-2 (ProxyJump through sys1)
ssh nuc        → Intel NUC (via Tailscale)
ssh claude-ws  → Claude Workstation VM (via Tailscale)
ssh gitlab-vm  → GitLab VM (home network direct)
```

## Design Principles

1. **Discovery before Destruction** — Never assume hardware names. Boot into RAM, probe with lsblk and ip link, record the truth, then build.
2. **Flatten before Pour** — Never trust runtime PHP merges for destructive installs. Compile Ignition into a single static JSON and verify it before wiping any disk.
3. **Bubble isolation** — Each hypervisor owns its own DNS/DHCP/K8s cluster inside VMs. The host stays clean (just KVM + bridge + storage).
4. **Local assets** — Never depend on the internet during PXE boot. Host FCOS kernel/initramfs/rootfs on System-1's LAN.
5. **Immutable infrastructure** — The hypervisor OS is a read-only bootc image. Changes go through the image pipeline, not ad-hoc package installs.

## Build Stages

The lab was built in stages. Each stage is documented in `stages/`:

| Stage | What | Status |
|-------|------|--------|
| Stage 1 | Bare-metal KVM foundation (PXE → Ignition → bootc) | Complete |
| Stage 2 | Storage pools (2x 1TB SSDs, libvirt pools) | Complete |
| Stage 3 | Kubernetes bubble (bind-kea VM + 3-node K8s + Cilium) | Complete |
| Stage 4 | Workloads (dashboard, sample apps) | In progress |

## Architecture

See `architecture/` for design documents:
- `bubble-model.md` — Self-contained K8s per hypervisor
- `network-factory.md` — PXE → Ignition → bootc pipeline
- `discovery-before-destruction.md` — The empirical probe methodology

## Artifacts (Reproducible Build Code)

See `artifacts/` for everything needed to rebuild from scratch:
- `hypervisor-image/` — Containerfile + rootfs configs
- `ignition/` — iPXE scripts, static Ignition, prep-machine, flatten script
- `cloud-init/` — VM provisioning configs
- `kea/` — DHCP config with iPXE client-class detection
- `scripts/` — Storage pool setup, VM creation

## Agent Rules

Read `AGENTS.md` for role definitions. Key rules:
- Read the relevant `systems/*.md` before operating on any machine
- Never modify System-1 hub services without explicit approval
- Use `artifacts/` for reproducible builds, not ad-hoc commands
- Check `.env` for credentials — never hardcode passwords in code
- The host stays clean — deploy services inside VMs, not on bare metal

## Orchestration

Multiple AI instances can operate on this lab simultaneously:
- Mac runs Claude Code (this repo, orchestrator)
- Claude Workstation VM runs Claude Code + Codex (builder)
- NUC runs clawhip/OpenClaw (Discord bot sessions)
- See `guides/orchestration-brain-surgery.md` for cross-instance context injection
