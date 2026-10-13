# AI Platform Lab

Hands-on lab work covering Kubernetes (EKS) security, retrieval-augmented generation on
Amazon Bedrock, and agentic AI with the Model Context Protocol — built to go deeper than
tutorial-following, with notes on what broke and why.

Everything here runs in a GitHub Codespace against a real AWS account. Each module has a
`NOTES.md` with findings rather than just working config.

---

## Modules

### 01 — EKS Security
Cluster built with Terraform and eksctl, then secured and tested.

- Workload identity two ways: **IRSA** (OIDC federation) and **EKS Pod Identity** — both
  configured, with notes on when each is the right choice
- **Access entries** mapping IAM principals to Kubernetes RBAC (the replacement for the
  `aws-auth` ConfigMap)
- **KMS envelope encryption** for Kubernetes Secrets in etcd
- Admission control with **Kyverno** — blocking privileged containers and `hostPath` mounts
- Default-deny **NetworkPolicy** and what it breaks on the way to least privilege
- **CIS Kubernetes Benchmark** via `kube-bench`, with triage of the findings
- Control plane audit logging to CloudWatch, queried with Logs Insights

### 02 — Bedrock RAG and Guardrails
A retrieval-augmented pipeline using managed AWS services.

- **Bedrock Knowledge Base** over documents in S3, with notes on chunking strategy and
  what happens to retrieval quality when chunk size and overlap are wrong
- **Bedrock Guardrails** — content filters, denied topics, PII redaction and contextual
  grounding checks, with the request path documented
- **Model invocation logging** to CloudWatch and S3 — what an auditor can actually see
- IAM and network isolation for Bedrock access

### 03 — Agentic AI and MCP
A small agent built from first principles rather than a framework, so the mechanics are visible.

- An **MCP server** exposing read-only tools to a model
- The **agent loop**: plan → call tool → observe result → repeat, with a stop condition
- **Guardrails**: read-only by default, credentials scoped per tool, PII redaction before
  inference, human approval before any state change, and audit logging of every tool call
- Notes on failure modes — prompt injection, runaway loops, over-trusted output

---

## Running this yourself

Open in a GitHub Codespace. The devcontainer installs the AWS CLI, kubectl, Helm,
Terraform, eksctl, k9s and Python 3.11.

```bash
aws sts get-caller-identity     # confirm credentials
cd 01-eks-security && cat NOTES.md
```

AWS credentials are supplied as Codespaces secrets and are never committed.

> **Cost note:** an EKS cluster is roughly $0.10/hour for the control plane plus node costs.
> Clusters here are created and destroyed per session.

---

## Background

I work on platform engineering and SRE — delivery platforms, Kubernetes, infrastructure
as code and observability — and have been building LLM-assisted tooling into production
operations. This repository is where I work through the parts I want to understand more
deeply, in the open.

Nothing in this repository comes from any employer's environment. All configuration,
data and examples are written from scratch for these labs.
