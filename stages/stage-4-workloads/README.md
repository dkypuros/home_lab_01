# Stage 4 — Workloads

## Status

Placeholder. Foundational workloads deployed. Further expansion planned.

## Deployed

| Workload | Description |
|---|---|
| Kubernetes Dashboard | Web UI for cluster visibility. Deployed via official manifest. |
| Sample web server | Basic nginx deployment to verify pod scheduling and service routing. |

## Planned

- Monitoring stack (Prometheus + Grafana)
- Network policies (Cilium)
- Persistent storage (local-path or NFS-backed PVCs)
- Additional application workloads TBD

## Access — Kubernetes Dashboard

```bash
kubectl proxy
# Access at: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
```

Token login: create a ServiceAccount with cluster-admin, get token via:
```bash
kubectl -n kubernetes-dashboard create token admin-user
```
