# Access Matrix

## Cockpit / Web UI Access

| System | Home WiFi URL | Tailscale URL | Lab Network URL | Tunnel Required? |
|--------|--------------|---------------|-----------------|-----------------|
| system-1 | http://192.168.86.20:9090 | http://system-1-2.tailfc4ba9.ts.net:9090 | http://10.0.0.1:9090 | No |
| system-2 | — | — | http://10.0.0.102:9090 | Yes — SSH tunnel via sys1 |
| nuc | http://192.168.86.47:9090 | http://oob-nuc.tailfc4ba9.ts.net:9090 | http://10.0.0.143:9090 | No |
| claude-workstation | — | — | — | Via Guacamole |
| guacamole-vm | — | http://guacamole-vm.tailfc4ba9.ts.net:8080/guacamole/ | — | No |
| gitlab-vm | http://192.168.86.48 (direct) | https://oob-nuc.tailfc4ba9.ts.net:8444 | — | No (proxied via NUC) |
| system-3 | — | — | — | Not provisioned |

## SSH Access

| System | SSH Shortcut | User | Auth | Notes |
|--------|-------------|------|------|-------|
| system-1 | `ssh student@sys1` | student | id_ed25519_hypervisor | Direct |
| system-2 | `ssh core@sys2` | core | key | ProxyJump through sys1 required |
| nuc | `ssh student@nuc` | student | key | Direct |
| claude-workstation | `ssh student@claude-ws` | student | password: see .env | Direct (home LAN) or via Tailscale |
| guacamole-vm | `ssh student@guacamole-vm` | student | key | Direct (home LAN) or via Tailscale |
| gitlab-vm | `ssh ubuntu@192.168.86.48` | ubuntu | key | Direct from Mac — system-1 cannot reach (macvtap) |
| system-3 | — | — | — | Not provisioned |

## Tunnel Reference

### system-2 Cockpit (admin/admin)
```
ssh -L 9090:10.0.0.102:9090 student@sys1
# then open http://localhost:9090
```

### system-2 SSH via ProxyJump
```
ssh -J student@sys1 core@10.0.0.102
# or with ~/.ssh/config alias: ssh core@sys2
```

## Key Constraints
- system-1 cannot reach macvtap VMs (claude-workstation, guacamole-vm, gitlab-vm) — use Mac or NUC
- system-2 has no Tailscale — all access via lab network through sys1
- gitlab-vm has no Tailscale — web access via NUC nginx proxy only
- system-3 is not provisioned — no access possible
