# 01 — Kubernetes and EKS Security

Securing a Kubernetes cluster layer by layer, and testing each control by trying to
break it. The Kubernetes-side work runs on a local `kind` cluster at no cost; the
AWS-specific controls are covered separately against EKS.

---

## Why these controls

Each control addresses a different stage of an attack, rather than being four variations
of the same idea:

| Control | Stops |
|---|---|
| Identity and RBAC | the wrong person getting in |
| Admission policy | the dangerous workload being created at all |
| Network policy | a compromised pod reaching anything else |
| Secrets handling | a compromise turning into stolen credentials |
| Audit logging and benchmarking | the compromise going unnoticed |

---

## Contents

```
kind/            local three-node cluster (Calico CNI for real NetworkPolicy)
rbac/            ServiceAccounts, Roles, RoleBindings, least-privilege tests
policies/        Kyverno admission policies
network/         default-deny and the allow rules that make it survivable
evidence/        raw tool output and captured failures
NOTES.md         what broke, what surprised me, what I'd change in production
```

---

## 1. Cluster

Three nodes in Docker, default CNI disabled so Calico can enforce NetworkPolicy —
kind's built-in `kindnet` accepts NetworkPolicy objects but does not enforce them,
which would make every policy test a false pass.

See [`kind/README.md`](kind/README.md).

## 2. RBAC and least privilege

A ServiceAccount scoped to a single namespace with only the verbs it needs, then
verified negatively — proving it *cannot* do the things it shouldn't.

```bash
kubectl auth can-i list secrets --as=system:serviceaccount:demo:restricted-sa
```

**Findings:** _to be written_

## 3. Admission control (Kyverno)

Policies blocking privileged containers, `hostPath` mounts, `hostNetwork`, images from
untrusted registries, and workloads with no resource limits. Each policy is tested by
attempting the thing it forbids.

**Findings:** _to be written_

## 4. Network policy

Default-deny ingress and egress, then the platform-level allow rules required to keep
the cluster functional — DNS above all.

**Findings:** _to be written_

## 5. Secrets

Demonstrating that a Kubernetes Secret is base64-encoded, not encrypted, and what
actually protects it: RBAC on the `secrets` verbs, encryption at rest, and keeping
secrets out of the cluster entirely by mounting them from an external store.

**Findings:** _to be written_

## 6. CIS benchmark

`kube-bench` against the cluster, with the findings triaged rather than listed — which
are real, which are irrelevant to a managed control plane, and which would block a
production rollout.

**Findings:** _to be written_

---

## AWS-specific controls

These cannot be demonstrated on a local cluster and are covered against EKS:

- **IRSA** — OIDC federation giving a pod its own IAM role
- **EKS Pod Identity** — the newer association-based alternative, and when to pick each
- **Access entries** — mapping IAM principals to Kubernetes RBAC, replacing `aws-auth`
- **KMS envelope encryption** of Secrets in etcd
- **GuardDuty EKS Protection** and control plane audit logs in CloudWatch

Where a control was written as code but not applied to a live cluster, it says so
explicitly rather than implying it was run.
