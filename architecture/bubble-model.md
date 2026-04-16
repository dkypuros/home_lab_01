# Bubble Model

## Concept

Each physical hypervisor hosts a self-contained Kubernetes environment called a "bubble." The host machine stays clean — no K8s components, no cluster networking on the bare metal.

## Isolation Properties

| Property | Detail |
|---|---|
| Network type | Isolated libvirt network (no NAT, no DHCP from libvirt) |
| Subnet per bubble | bubble-a: `10.2.0.0/24`, bubble-b: `10.3.0.0/24`, etc. |
| DNS/DHCP owner | Dedicated BIND+Kea VM inside the bubble |
| K8s node placement | Only on the bubble network |
| External access | NAT gateway via infra VM (not the host) |

## bubble-a Layout (System-2)

```
System-2 (hypervisor, br0 on 10.0.0.x)
└── libvirt isolated network: bubble-a (10.2.0.0/24)
    ├── bind-kea-a VM  — DNS (cluster-a.lab) + DHCP + NAT gateway
    ├── k8s-cp-a       — control plane (10.2.0.10x)
    ├── k8s-w1-a       — worker node
    └── k8s-w2-a       — worker node
```

## Repeating Pattern

| Bubble | Hypervisor | Subnet |
|---|---|---|
| bubble-a | System-2 | 10.2.0.0/24 |
| bubble-b | System-3 | 10.3.0.0/24 |
| bubble-c | System-4 | 10.4.0.0/24 |

## Key Rules

- The host never joins the bubble network.
- The infra VM (bind-kea-a) is the only path in/out of the bubble for pod traffic.
- Adding a new bubble requires only a new libvirt network + infra VM on the target hypervisor.
- Bubbles are independent — one failing cluster does not affect others.
