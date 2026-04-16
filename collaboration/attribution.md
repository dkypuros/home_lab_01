# Attribution — Standing on Jason's Shoulders

## The Foundation

This lab exists because of the work of **Jason Nagin** ([@JasonN3](https://github.com/JasonN3), Red Hat). Jason built a complete, open-source toolkit for immutable infrastructure: bootc-based container images that become operating systems, PHP-driven Ignition configs that provision machines on first boot, and a reboot manager that keeps clusters healthy during rolling updates.

I found Jason's repositories while trying to figure out how to build a bare-metal Kubernetes lab at home. I'd been struggling with the classic problem: how do you install an OS on a machine in a way that's repeatable, immutable, and doesn't involve clicking through an installer? Jason had already solved it.

## What Jason Built

Jason's four core projects form a complete pipeline:

### 1. [ignition](https://github.com/JasonN3/ignition) — The Provisioning Brain

A PHP web application that dynamically generates [Ignition](https://coreos.github.io/ignition/) JSON configs for Fedora CoreOS machines. When a machine PXE boots, it fetches an iPXE script from this server, which tells it how to boot the FCOS live image and where to find its identity (hostname, SSH keys, services to enable). The PHP fragments are modular — SSH config in one file, hostname in another, disk partitioning in another — and they merge at request time into a single Ignition JSON.

This is the project I used most directly. The container running on my System-1 at port 80 is literally called `jasonn3-ignition-lab`. I cloned his PHP source, added my own customization layer (`lab_bootstrap.php` for per-node hardware mappings, `bridge.ign.php` for KVM bridge networking, `discovery.ign.php` for safe hardware probing), and kept the core merge architecture intact.

### 2. [kube_node](https://github.com/JasonN3/kube_node) — The Immutable Node Image

A Containerfile that builds a complete Kubernetes node as an OCI container image. It starts from `quay.io/fedora/fedora-coreos:stable`, layers in kubeadm, kubelet, containerd, and all the kernel tuning a K8s node needs, and produces an image you can deploy with `bootc switch`. The node's entire identity is baked into the image — you don't SSH in and install packages, you rebuild the image and roll it out.

This was the pattern I forked for my `hypervisor_node` image. Same Containerfile structure, same FCOS base, same bootc deployment — but I swapped kubeadm and kubelet for qemu-kvm and libvirt. Jason's kube_node makes Kubernetes workers; my hypervisor_node makes KVM hypervisors. Same factory, different product.

### 3. [build-container-installer](https://github.com/JasonN3/build-container-installer) — ISO from Image

Takes any bootc container image and produces a bootable installation ISO. This is the "USB stick" path — useful for machines that can't PXE boot or for cloud deployments. I have it in my working tree but haven't needed it because my lab uses PXE exclusively.

### 4. [kubernetes_reboot_manager](https://github.com/JasonN3/kubernetes_reboot_manager) — Fleet Lock

A fleet-lock server that coordinates node reboots. When Zincati (the FCOS update manager) wants to reboot a node after an OS update, it asks the fleet-lock server for permission. The server ensures only one node reboots at a time, preventing cascading failures. Referenced in my configs but not yet deployed — it becomes critical once the cluster is in production use.

## How I Diverged

Jason's tools assume a specific workflow: you know your hardware, you build images, you PXE boot, and machines come up as Kubernetes nodes. My lab needed more flexibility, so I extended the pattern in several ways:

### The Discovery Act

Jason's Ignition configs assume you already know the disk device name (`/dev/sda`) and NIC name (`eno1`). In my lab, I didn't — and guessing wrong during a destructive install means wiping the wrong disk. So I added a "Discovery Act": a safe, non-destructive boot mode that loads FCOS entirely into RAM, lets you SSH in and run `lsblk` and `ip link` to capture the real hardware names, and then powers off. Only after recording the truth do you commit to the destructive install. Jason's code doesn't need this because he knows his hardware; I needed it because I was learning mine.

### Flattened Ignition

Jason's Ignition server generates configs dynamically by merging PHP fragments at request time. This is elegant for development but fragile for destructive installs — if one PHP fragment has a bug, or if a network request fails during the merge, the machine gets a partial config and the install is ruined. I discovered this the hard way when `ssh.ign.php` silently failed to load during a boot, leaving a machine with no SSH access after wiping its disk.

My fix was to "flatten" the Ignition config: pre-fetch all fragments from the PHP server, merge them into a single static JSON file, verify it's complete, and point the iPXE boot at the static file instead of the dynamic endpoint. The PHP server is still the source of truth for development; the static file is what gets used for production pours.

### Multi-Role Nodes

Jason's pipeline produces one type of node: Kubernetes workers. My lab needed two: KVM hypervisors (for running VMs) and Kubernetes workers (running inside those VMs). I added a role system to `lab_bootstrap.php` where each node has a `role` field (`hypervisor` or `kube_node`) that controls which Ignition fragments activate. Hypervisors get bridge configs and libvirt; kube nodes get kubeadm and containerd.

### The Bubble Architecture

This is the biggest divergence. Jason's design is flat: bare-metal machines become Kubernetes nodes, all on one network. My design nests Kubernetes inside KVM: bare-metal machines become hypervisors, each hypervisor hosts an isolated "bubble" with its own DNS, DHCP, and Kubernetes cluster. The bubbles are self-contained — destroy one and the others keep running. This came from wanting to simulate multiple independent clusters (like a telco edge deployment) on a small number of physical machines.

## The Lineage

```
Jason's kube_node pattern
    │
    ├── My hypervisor_node (swap K8s for KVM)
    │       │
    │       └── System-2 hypervisor (bare metal)
    │               │
    │               └── Bubble-A (isolated libvirt network)
    │                       │
    │                       ├── bind-kea-a VM (DNS + DHCP)
    │                       └── Kubernetes cluster
    │                               ├── k8s-cp-1
    │                               ├── k8s-worker-1
    │                               └── k8s-worker-2
    │
Jason's ignition server
    │
    ├── My lab_bootstrap.php (multi-role customization)
    ├── My discovery.ign.php (safe hardware probing)
    ├── My bridge.ign.php (KVM bridge networking)
    └── My flatten_ignition.py (static JSON for safe pours)
```

## To Jason

Your tools work. The bootc image mode deployment works — I proved it with `bootc switch` pulling a custom hypervisor image from a local registry. The PHP Ignition server works — it's been serving configs to my machines for weeks. The pattern of "OS as a container image" is exactly right.

The things I added — discovery probing, Ignition flattening, multi-role nodes, bubble isolation — are all extensions of your foundation, not replacements. If any of them are useful to you, take them. The `lab_bootstrap.php` per-node config pattern and the `flatten_ignition.py` static export might be worth considering upstream.

Thank you for open-sourcing this. It saved me months.

## License Compliance

All four of Jason's projects are licensed under **GPLv3**. This lab's modifications maintain GPLv3 compliance:

- Original author credited (Jason Nagin, @JasonN3)
- License preserved
- Source code available (this repository)
- Modifications documented (this file + `architecture/` docs)
- Derivative works maintain GPLv3
