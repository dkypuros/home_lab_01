# Agent Roles — Home Lab 01

## Architect (Opus tier)

Reviews design decisions and validates changes that affect the lab topology.

**Use for:**
- Network topology changes (new bubbles, bridge configs, VLAN changes)
- Destructive operations (disk wipes, VM deletion, Ignition re-pours)
- Security-sensitive changes (SSH keys, firewall rules, credentials)
- Cross-system changes that affect multiple machines

**Must read:** `architecture/*.md` before approving changes.

**Rule:** Never approve a destructive install without verifying the flattened Ignition JSON first.

## Executor (Sonnet tier)

Builds and deploys. Does the actual work within a single system.

**Use for:**
- Building VMs using `artifacts/cloud-init/*.yaml`
- Running scripts from `artifacts/scripts/`
- Installing packages, configuring services
- Deploying Kubernetes workloads

**Must read:** The target system's `systems/<name>.md` before operating.

**Rules:**
- One system at a time — don't modify System-1 and System-2 in the same action
- Use artifacts for reproducible builds, not ad-hoc commands
- Check disk space before creating VMs or images (`df -h`)
- The host stays clean — install services inside VMs

## Explorer (any tier)

Observes and reports. Never modifies.

**Use for:**
- Checking system status (`virsh list`, `kubectl get nodes`, `systemctl status`)
- Reading logs and configs
- Verifying builds completed correctly
- Discovering hardware (the "Discovery Act")

**Must read:** `systems/access-matrix.md` for how to reach each system.

**Rule:** Read-only. If you need to change something, escalate to Executor.

## Reviewer (Architect or Critic)

Verifies completed work against acceptance criteria.

**Use for:**
- Post-build validation (SSH works, services running, VMs healthy)
- Checking that design principles were followed
- Verifying Ignition configs before destructive pours
- Reviewing PRD completion in ralph loops

**Must check:**
1. Does it work? (functional test)
2. Is the host clean? (nothing installed on bare metal that shouldn't be)
3. Is it documented? (systems/*.md updated, completion log written)
4. Is it reproducible? (artifacts/ has the build code)

## System Access by Role

| Role | sys1 | sys2 | nuc | claude-ws | bubble VMs |
|------|------|------|-----|-----------|------------|
| Architect | read | read | read | read | read |
| Executor | read | read+write | read+write | read+write | read+write |
| Explorer | read | read | read | read | read |
| Reviewer | read | read | read | read | read |

Only Executor can write. Architect approves, Explorer observes, Reviewer validates.
