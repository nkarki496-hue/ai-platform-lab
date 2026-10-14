# RBAC and least privilege

Kubernetes authorisation is deny-by-default: an identity can do nothing until a
binding grants it something. The exercise here builds a minimal identity and then
verifies it by proving what it *cannot* do.

## The three objects

| Object | Purpose |
|---|---|
| **ServiceAccount** | the identity a pod runs as |
| **Role** | a set of permissions, scoped to one namespace |
| **RoleBinding** | attaches the Role to the identity — without it the Role does nothing |

Cluster-wide equivalents are **ClusterRole** and **ClusterRoleBinding**. A ClusterRole
bound with a *RoleBinding* applies only within that namespace, which is the usual way to
reuse a common permission set without granting it everywhere.

## Apply

```bash
kubectl apply -f .
./test-permissions.sh
```

## Why negative testing matters

`kubectl auth can-i` answers the same question the API server asks on every request. A
permissions test that only checks the allowed actions proves nothing about blast radius —
the useful assertions are the denials.

## Findings

_to be written_
