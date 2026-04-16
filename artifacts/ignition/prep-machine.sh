#!/bin/bash
set -ex

# Stage 1: The Persistent Pour
# Pull the hypervisor_node image from the local registry and write it to disk.
BOOTC_IMAGE_REF="${BOOTC_IMAGE_REF:-10.0.0.1:5000/hypervisor_node:latest}"

echo "=== Switching to bootc image: ${BOOTC_IMAGE_REF} ==="
bootc switch --transport registry "${BOOTC_IMAGE_REF}"

echo "=== bootc switch complete. Rebooting into persistent hypervisor. ==="
systemctl reboot
