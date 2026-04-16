#!/bin/bash
# Run on System-1 to create the Claude Code workstation VM
# Prerequisites:
#   - Fedora Cloud Base image at /var/lib/libvirt/images/Fedora-Cloud-Base-Generic-43-1.6.x86_64.qcow2
#   - genisoimage installed (dnf install -y genisoimage)
#   - cloud-init user-data and meta-data files in current directory

set -ex

# Create disk from cloud image
cp /var/lib/libvirt/images/Fedora-Cloud-Base-Generic-43-1.6.x86_64.qcow2 \
   /var/lib/libvirt/images/claude-workstation.qcow2
qemu-img resize /var/lib/libvirt/images/claude-workstation.qcow2 40G

# Create cloud-init seed ISO
genisoimage -output /var/lib/libvirt/images/claude-ws-seed.iso \
  -volid cidata -joliet -rock \
  claude-workstation-user-data claude-workstation-meta-data

# Rename for cloud-init convention
mv claude-workstation-user-data user-data 2>/dev/null || true
mv claude-workstation-meta-data meta-data 2>/dev/null || true

# Create VM on macvtap (home network)
virt-install \
  --name claude-workstation \
  --ram 8192 --vcpus 4 \
  --disk /var/lib/libvirt/images/claude-workstation.qcow2,format=qcow2 \
  --disk /var/lib/libvirt/images/claude-ws-seed.iso,device=cdrom \
  --network type=direct,source=enp8s0f0,source_mode=bridge,model=virtio \
  --os-variant fedora-unknown \
  --graphics vnc,listen=127.0.0.1 \
  --console pty,target_type=serial \
  --import \
  --noautoconsole

echo "VM created. Wait ~3 min for cloud-init to finish."
echo "Then install Tailscale: ssh student@<ip> 'curl -fsSL https://tailscale.com/install.sh | sudo sh && sudo tailscale up --hostname claude-workstation'"
echo "Then install desktop for Guacamole: ssh student@<ip> 'sudo dnf install -y openbox tigervnc-server firefox xterm'"
