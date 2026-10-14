# Local cluster (kind)

A three-node Kubernetes cluster running in Docker inside the Codespace. Costs nothing
and covers the Kubernetes-side security work: RBAC, admission control, network policy,
pod security and CIS benchmarking.

The default CNI is disabled so Calico can be installed — kind's built-in `kindnet` does
not enforce NetworkPolicy, which would make the network policy exercises meaningless.

## Create

```bash
cd 01-eks-security/kind
kind create cluster --config kind-cluster.yaml
kubectl get nodes          # all three will show NotReady until the CNI is installed
```

Three nodes rather than two: with a second worker, a node can be cordoned and drained
while pods still have somewhere to reschedule, which is what makes Pod Disruption Budget
testing meaningful.

## Install Calico (needed for NetworkPolicy enforcement)

```bash
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/calico.yaml
kubectl -n kube-system rollout status daemonset/calico-node --timeout=180s
kubectl get nodes          # now Ready
```

## Destroy

```bash
kind delete cluster --name seclab
```

## What this cluster cannot do

Anything AWS-specific: IRSA, EKS Pod Identity, access entries, KMS envelope encryption
of etcd, GuardDuty EKS Protection. Those are covered separately against a real EKS
cluster, or documented as code without being applied.
