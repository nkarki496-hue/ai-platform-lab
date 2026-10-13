#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing eksctl"
ARCH=amd64
curl -sSL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_Linux_${ARCH}.tar.gz" \
  | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin/
eksctl version


echo "==> Installing kind (local Kubernetes in Docker)"
curl -sSLo /tmp/kind "https://kind.sigs.k8s.io/dl/v0.23.0/kind-linux-amd64"
chmod +x /tmp/kind
sudo mv /tmp/kind /usr/local/bin/kind
kind version

echo "==> Installing k9s (terminal UI for Kubernetes)"
curl -sSL "https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz" \
  | tar xz -C /tmp k9s
sudo mv /tmp/k9s /usr/local/bin/

echo "==> Installing Python packages for the AI labs"
pip install --quiet --upgrade boto3 anthropic requests python-dotenv

echo "==> Adding kubectl autocomplete + aliases"
{
  echo 'source <(kubectl completion bash)'
  echo 'alias k=kubectl'
  echo 'complete -o default -F __start_kubectl k'
} >> "$HOME/.bashrc"

echo ""
echo "===================================================="
echo " Lab environment ready."
echo ""
echo "  eksctl   $(eksctl version 2>/dev/null)"
echo "  kubectl  $(kubectl version --client -o json 2>/dev/null | head -c 0)installed"
echo "  terraform $(terraform version | head -1)"
echo ""
echo " Next: run 'aws sts get-caller-identity' to confirm"
echo " your AWS credentials are working."
echo "===================================================="
