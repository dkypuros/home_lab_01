# VS Code Remote SSH

## SSH Config Shortcuts

Add to `~/.ssh/config` on your Mac:

```sshconfig
Host claude-ws
  HostName 10.0.0.50
  User core
  IdentityFile ~/.ssh/id_ed25519

Host sys1
  HostName 10.0.0.1
  User core
  IdentityFile ~/.ssh/id_ed25519

Host sys2
  HostName 10.0.0.2
  User core
  IdentityFile ~/.ssh/id_ed25519
  ProxyJump sys1

Host nuc
  HostName 10.0.0.10
  User david
  IdentityFile ~/.ssh/id_ed25519

Host gitlab-vm
  HostName 10.0.0.20
  User git
  IdentityFile ~/.ssh/id_ed25519
```

## Extension

Install: **Remote - SSH** (`ms-vscode-remote.remote-ssh`)

## Connect

1. Open Command Palette: `Cmd+Shift+P`
2. Select: `Remote-SSH: Connect to Host...`
3. Choose shortcut (e.g., `sys2`)

VS Code handles ProxyJump automatically — no manual tunnel needed for sys2.

## Notes

- sys2 is behind sys1. The ProxyJump entry handles the hop transparently.
- After connecting, open any folder on the remote machine via `File > Open Folder`.
- Extensions installed locally are not automatically available remotely — install them on the remote host as needed.
