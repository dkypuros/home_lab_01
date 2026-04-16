#!/bin/bash
# Run on System-2 to set up the 1TB SSD storage pools
# Prerequisites: /dev/sdb and /dev/sdc are available

set -ex

# Partition and format ssd-a
wipefs -a /dev/sdb
parted -s /dev/sdb mklabel gpt mkpart ssd-a 0% 100%
mkfs.xfs -f -L ssd-a /dev/sdb1

# Partition and format ssd-b
wipefs -a /dev/sdc
parted -s /dev/sdc mklabel gpt mkpart ssd-b 0% 100%
mkfs.xfs -f -L ssd-b /dev/sdc1

# Create mount points
mkdir -p /var/lib/libvirt/images/ssd-a /var/lib/libvirt/images/ssd-b

# Create systemd mount units (note: \x2d escaping for hyphens)
UNIT_A=$(systemd-escape --path /var/lib/libvirt/images/ssd-a).mount
UNIT_B=$(systemd-escape --path /var/lib/libvirt/images/ssd-b).mount

cat > /etc/systemd/system/$UNIT_A << 'UNIT'
[Unit]
Description=Mount ssd-a storage
[Mount]
What=/dev/disk/by-partlabel/ssd-a
Where=/var/lib/libvirt/images/ssd-a
Type=xfs
Options=defaults
[Install]
WantedBy=local-fs.target
UNIT

cat > /etc/systemd/system/$UNIT_B << 'UNIT'
[Unit]
Description=Mount ssd-b storage
[Mount]
What=/dev/disk/by-partlabel/ssd-b
Where=/var/lib/libvirt/images/ssd-b
Type=xfs
Options=defaults
[Install]
WantedBy=local-fs.target
UNIT

systemctl daemon-reload
systemctl enable --now $UNIT_A
systemctl enable --now $UNIT_B

# Create libvirt pools
systemctl start libvirtd
virsh pool-define-as ssd-a dir --target /var/lib/libvirt/images/ssd-a
virsh pool-start ssd-a
virsh pool-autostart ssd-a
virsh pool-define-as ssd-b dir --target /var/lib/libvirt/images/ssd-b
virsh pool-start ssd-b
virsh pool-autostart ssd-b

echo "Storage pools ready"
df -h /var/lib/libvirt/images/ssd-a /var/lib/libvirt/images/ssd-b
virsh pool-list --all
