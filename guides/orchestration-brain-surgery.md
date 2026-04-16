# Orchestration Brain Surgery

## Concept

Cross-instance context injection. Write markdown files to `~/.omc/state/` on a remote machine via SSH. The Claude Code session running on that machine picks up the context automatically.

## Use Case

A Mac Claude Code session needs to hand off knowledge (SSH keys, shortcuts, task state) to a Claude Code session running on the claude-workstation VM — without the remote session being present in the conversation.

## Procedure

### 1. Prepare the context file locally

Write a markdown file describing the state to inject:

```bash
cat > /tmp/inject-context.md << 'EOF'
# Injected Context

## SSH Key
Public key for lab access: ssh-ed25519 AAAA... david@mac

## Tailscale Shortcut
nuc tailscale fqdn: nuc.tail1234.ts.net

## Current Task
Setting up claude-workstation. Next: install oh-my-claudecode.
EOF
```

### 2. Write the file to the remote machine

```bash
ssh claude-ws "mkdir -p ~/.omc/state"
scp /tmp/inject-context.md claude-ws:~/.omc/state/injected-2026-04-09.md
```

### 3. Remote Claude Code picks it up

On the claude-workstation, Claude Code reads `~/.omc/state/` as part of its context loading. The injected file is available in the next session or tool call.

## Real Example

Mac session wrote two files to claude-workstation:

| File | Content |
|---|---|
| `~/.omc/state/ssh-keys.md` | Lab SSH public key and known hosts |
| `~/.omc/state/tailscale-shortcut.md` | Tailscale auth token shortcut command |

Remote Claude Code used both in subsequent steps without manual re-entry.

## Notes

- Files persist across sessions until manually removed.
- Use dated filenames to avoid collisions (`injected-YYYY-MM-DD.md`).
- State directory: `~/.omc/state/` on the target machine.
- Works for any two machines with SSH access between them.
