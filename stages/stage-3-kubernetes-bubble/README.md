# Stage 3 — Kubernetes Bubble

## Goal

Create an isolated Kubernetes cluster inside bubble-a on System-2. All K8s traffic stays on the bubble network. External access routes through the infra VM.

## Step 1 — bubble-a libvirt Network

```bash
virsh net-define bubble-a.xml
virsh net-start bubble-a
virsh net-autostart bubble-a
```

bubble-a.xml key properties:
- Mode: isolated (no NAT, no DHCP from libvirt)
- Bridge: virbr-bubble-a
- No `<dhcp>` block — Kea inside bind-kea-a handles DHCP

## Step 2 — bind-kea-a VM

| Service | Detail |
|---|---|
| BIND zone | `cluster-a.lab` |
| Kea pool | `10.2.0.100` – `10.2.0.199` |
| Static leases | control plane and worker nodes |
| NAT gateway | iptables MASQUERADE on eth0 (br0 side) |

This VM is the only path for bubble traffic to reach the outside network.

## Step 3 — K8s VMs

| VM | IP | Role |
|---|---|---|
| k8s-cp-a | 10.2.0.10 | control plane |
| k8s-w1-a | 10.2.0.11 | worker |
| k8s-w2-a | 10.2.0.12 | worker |

All VMs: FCOS or compatible OS, 2+ vCPU, 4+ GB RAM.

## Step 4 — kubeadm Bootstrap

Fix zram swap before init (kubeadm requires swap off):

```bash
swapoff -a
systemctl stop swap-create@zram0
systemctl mask swap-create@zram0
```

On control plane:

```bash
kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=10.2.0.10
```

Copy kubeconfig:

```bash
mkdir -p ~/.kube
cp /etc/kubernetes/admin.conf ~/.kube/config
```

Join workers:

```bash
kubeadm join 10.2.0.10:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>
```

## Step 5 — Cilium CNI

Version: v1.19.1

```bash
cilium install --version 1.19.1
cilium status --wait
```

## Validation

```bash
kubectl get nodes
# All nodes: Ready

kubectl get pods -A
# All system pods: Running
```
