# Cockpit

## Systems with Cockpit

| System | Address | Notes |
|---|---|---|
| System-1 | https://10.0.0.1:9090 | Direct access on lab network |
| NUC | https://10.0.0.10:9090 | Direct access on lab network |
| System-2 | https://10.0.0.2:9090 | Requires tunnel (not directly reachable from Mac) |

## Login Credentials

| System | Username | Password |
|---|---|---|
| System-1 | `core` | SSH key auth (use `sudo` password if set) |
| NUC | `david` | local password |
| System-2 | `core` | SSH key auth |

## Tunnel for System-2

System-2 is behind System-1. SSH tunnel required:

```bash
ssh -L 9091:10.0.0.2:9090 sys1 -N
```

Then open: https://localhost:9091

## Mobile Access via NUC Tailscale

NUC has a Tailscale FQDN. Access Cockpit from mobile or outside the local network:

```
https://<nuc-tailscale-fqdn>:9090
```

Find the FQDN:
```bash
tailscale status
```

## Install Cockpit on a New System

```bash
# Fedora / RHEL / CoreOS
rpm-ostree install cockpit cockpit-machines
systemctl enable --now cockpit.socket
firewall-cmd --permanent --add-service=cockpit
firewall-cmd --reload
```

For bootc-managed systems, add `cockpit` to the Containerfile and rebuild the image.
