# Evolution Notes — From Jason's Repos to Golden Lab 03

These are the raw notes documenting how this lab evolved from studying Jason Nagin's repositories to a working multi-system infrastructure.

## Timeline

### Phase 1: Discovery (Early April 2026)

Downloaded and studied Jason's four core repositories:
- `kube_node` — understood the bootc Containerfile pattern
- `ignition` — understood the PHP Ignition fragment architecture
- `build-container-installer` — noted as USB/ISO alternative to PXE
- `kubernetes_reboot_manager` — noted for future fleet-lock deployment

Key insight: Jason had solved the "how do you install an immutable OS on bare metal" problem with FCOS + bootc + Ignition. The pattern was: build an OCI image with your software, serve an Ignition config that tells the machine to pull it, PXE boot the machine, and let the pipeline handle the rest.

### Phase 2: Alpine Attempt (April 4-8, 2026)

First attempt used Alpine Linux on System-1 as the hub with dnsmasq for DHCP/DNS. This worked for basic PXE booting but lacked the image management pipeline that Jason's tools provided. The Alpine approach was too manual — every change required SSH and package installs.

### Phase 3: Fedora Pivot (April 9, 2026)

Rebuilt System-1 on Fedora 43 Server. This gave us:
- Kea DHCP (replacing dnsmasq) with proper client-class detection for iPXE
- BIND DNS with lab.local zone
- Jason's `ignition` container running as `jasonn3-ignition-lab` on port 80
- A local OCI registry at 10.0.0.1:5000

11 deviations from the original plan were documented during the rebuild.

### Phase 4: Golden Lab 01 — Jason's Pattern Applied

Created the `5_fcos_bootc_jasonn3_image_mode_cluster` folder (literally named after Jason) in the golden progression. This was the first attempt to use Jason's full pipeline:
- kube_node Containerfile adapted for the lab
- Ignition PHP server deployed
- prep-machine.sh with bootc switch

### Phase 5: Golden Lab 03 — Divergence (April 14-16, 2026)

This is where the lab grew beyond Jason's original scope:

**Discovery before Destruction** — Jason's configs assume known hardware. We added a safe RAM-only boot to discover device names empirically before committing to a destructive install.

**hypervisor_node** — Forked the kube_node Containerfile pattern but replaced Kubernetes packages with KVM/libvirt. Same bootc pipeline, different payload.

**Flattened Ignition** — After the PHP merge pipeline silently dropped `ssh.ign.php` during a destructive install (leaving a machine with no SSH access), we added a flatten step that pre-compiles all fragments into a single verified JSON file.

**Bubble architecture** — Instead of flat bare-metal K8s nodes, we nested Kubernetes inside KVM VMs with dedicated DNS/DHCP per cluster.

**Multi-AI orchestration** — Claude Code on the Mac orchestrated Claude Code on a workstation VM, which built the Kubernetes bubble on System-2 autonomously. This wasn't in anyone's original plan.

## What's Jason's vs What's Ours

| Component | Origin | Status |
|-----------|--------|--------|
| Ignition PHP server | Jason's `ignition` repo | Running as-is with our customization layer on top |
| kube_node Containerfile | Jason's `kube_node` repo | Pattern forked into `hypervisor_node` |
| build-container-installer | Jason's repo | Available, unused (we PXE boot) |
| kubernetes_reboot_manager | Jason's repo | Referenced, not deployed yet |
| lab_bootstrap.php | Ours | Per-node hardware mapping + role system |
| bridge.ign.php | Ours | KVM bridge networking via Ignition |
| discovery.ign.php | Ours | Safe RAM-only hardware probing |
| flatten_ignition.py | Ours | Static JSON export for safe installs |
| Bubble architecture | Ours | Nested K8s inside KVM with own DNS/DHCP |
| Kea client-class detection | Ours | iPXE chain-breaking in DHCP |
| Multi-AI orchestration | Ours | Claude Code + Codex across machines |

## Questions Jason Asked

> "Did you use ignition?"

Yes. The `jasonn3-ignition-lab` container runs on System-1 port 80. We use it for both discovery and install profiles. We added `lab_bootstrap.php` for multi-node customization and `bridge.ign.php` for KVM bridging.

> "kube_node — Ignition is for the old OS tree deployment. I don't know if this is compatible with the new image mode deployment. I haven't tested it."

It works. We proved it: `bootc switch --transport registry 10.0.0.1:5000/hypervisor_node:latest` successfully switches from the base FCOS image to a custom bootc image. The Ignition config runs on the initial FCOS install, triggers `prep-machine.sh`, which calls `bootc switch`, which pulls the custom image and reboots into it. Ignition handles the first boot identity; bootc handles the OS image.

> "kube_node — Is an image mode for Fedora image with Kubernetes customizations built in?"

Yes, exactly. And the same pattern works for non-Kubernetes images. Our `hypervisor_node` is an image mode Fedora image with KVM/libvirt customizations built in. The Containerfile pattern is the same — just different packages in the `dnf install` line.
