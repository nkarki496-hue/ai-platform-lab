# Environment Setup

This repository ships its own development environment. Opening it in a GitHub Codespace
gives a Linux container with every tool the labs need already installed — no local
installation, and anyone who clones it gets an identical setup.

---

## How the environment builds itself

Two files do the work, and Codespaces runs them automatically.

### `.devcontainer/devcontainer.json`

The recipe. Read before the machine starts.

```jsonc
"image": "mcr.microsoft.com/devcontainers/base:ubuntu-22.04",
"features": {
  "ghcr.io/devcontainers/features/aws-cli:1": {},
  "ghcr.io/devcontainers/features/kubectl-helm-minikube:1": { "minikube": "none" },
  "ghcr.io/devcontainers/features/terraform:1": {},
  "ghcr.io/devcontainers/features/python:1": { "version": "3.11" },
  "ghcr.io/devcontainers/features/github-cli:1": {},
  "ghcr.io/devcontainers/features/docker-in-docker:2": {}
},
"postCreateCommand": "bash .devcontainer/post-create.sh"
```

**`features`** are maintained install scripts from the devcontainer project. Declaring one
installs that tool correctly, with its dependencies and PATH handled. This is where the
AWS CLI, kubectl, Helm, Terraform, Python 3.11 and Docker-in-Docker come from.

`minikube` is explicitly set to `none` — the labs use kind instead, and installing both
wastes build time.

**`docker-in-docker`** matters more than it looks: kind runs Kubernetes nodes as Docker
containers, so without a Docker daemon inside the codespace there is no cluster.

**`postCreateCommand`** runs a script of our own after the container is built, for tools
that have no feature.

### `.devcontainer/post-create.sh`

Installs what the features don't cover:

| Tool | Why |
|---|---|
| **kind** | runs the local Kubernetes cluster |
| **k9s** | terminal UI for inspecting cluster state quickly |
| **boto3, anthropic, requests** | Python libraries for the Bedrock and agent labs |
| kubectl autocomplete + `k` alias | quality of life |

### Build order

```
pull ubuntu-22.04 base image
        ↓
install features (aws-cli, kubectl, helm, terraform, python, docker)
        ↓
run post-create.sh (kind, k9s, python packages, shell config)
        ↓
VS Code opens
```

First build takes 4–6 minutes. Rebuilds are faster because layers are cached.

---

## What kind is, and why these labs use it

**kind** stands for *Kubernetes IN Docker*. It runs a genuine Kubernetes cluster where each
node is a Docker container rather than a VM or an EC2 instance.

The cluster config here creates three containers — one control plane, two workers — each
running a real kubelet, API server, etcd and scheduler. `kubectl` cannot tell the
difference between this and a cloud cluster.

| | kind | Amazon EKS |
|---|---|---|
| Nodes are | Docker containers | EC2 instances |
| Control plane | yours, in a container | managed by AWS |
| Cost | free | ~$0.10/hour plus node cost |
| Time to create | about 60 seconds | about 15 minutes |
| Lives | inside the codespace | in an AWS account |

**Covered perfectly by kind:** RBAC, admission control, NetworkPolicy, Pod Security
Standards, secrets handling, CIS benchmarking, and every workload troubleshooting
scenario — CrashLoopBackOff, OOMKilled, Pending, probe failures, disruption budgets.
All of this is pure Kubernetes and behaves identically.

**Not possible on kind:** anything AWS-specific — IRSA, EKS Pod Identity, access entries,
KMS envelope encryption of etcd, AWS load balancer integration, GuardDuty EKS Protection.
Those require a real EKS cluster and are handled separately.

Two further deliberate choices in `01-eks-security/kind/kind-cluster.yaml`:

- **The default CNI is disabled.** kind's built-in `kindnet` accepts NetworkPolicy objects
  but does not enforce them — every policy test would pass whether the policy worked or
  not. Calico is installed instead so the enforcement is real.
- **Two workers, not one.** With a second worker you can cordon and drain a node and watch
  pods actually reschedule, which is most of what Pod Disruption Budgets are about.

---

## Getting started

1. On the repository page: **Code** → **Codespaces** → **Create codespace on main**
2. Wait for the build (4–6 minutes)
3. Open a terminal and verify:

```bash
kind version
kubectl version --client
terraform version
docker ps
```

If `kind` is not found, the post-create script did not complete. Press <kbd>F1</kbd>,
run **Rebuild Container**, and wait again.

### Creating the local cluster

```bash
cd 01-eks-security/kind
mkdir -p audit audit-logs
kind create cluster --config kind-cluster.yaml
kubectl get nodes        # three nodes, all NotReady until the CNI is installed

kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/calico.yaml
kubectl -n kube-system rollout status daemonset/calico-node --timeout=180s
kubectl get nodes        # now Ready
```

### Tearing down

```bash
kind delete cluster --name seclab
```

---

## Cost and housekeeping

**Codespaces** includes 60 core-hours per month on the free tier — roughly 30 hours on the
default 2-core machine. The codespace does not stop the moment you close the tab, so stop
it explicitly: **Code** → **Codespaces** → the three dots beside the codespace → **Stop**.

**kind costs nothing.** It runs inside the codespace.

**AWS does cost.** For the modules that need real AWS — EKS-specific identity controls and
the Bedrock labs — credentials are supplied as Codespaces secrets (`AWS_ACCESS_KEY_ID` and
`AWS_SECRET_ACCESS_KEY`, scoped to this repository) and are never committed. Clusters are
created and destroyed within the same session, and a billing alert is set before any of it
is run.

---

## Repository hygiene

`.gitignore` blocks Terraform state and variable files, `.env`, private keys, kubeconfig
files and Python caches. Nothing in this repository comes from any employer environment —
all configuration and examples are written from scratch for these labs.
