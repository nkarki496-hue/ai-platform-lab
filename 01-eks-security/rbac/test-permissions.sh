#!/usr/bin/env bash
# Verify RBAC the way it should be verified: by proving what the identity
# CANNOT do, not just what it can. A permissions test that only checks the
# happy path tells you nothing about the blast radius.
SA="system:serviceaccount:demo:restricted-sa"

echo "=== Should be allowed ==="
echo -n "list pods in demo:            "; kubectl auth can-i list pods        -n demo --as=$SA
echo -n "get pod logs in demo:         "; kubectl auth can-i get pods/log     -n demo --as=$SA

echo ""
echo "=== Should be denied ==="
echo -n "list secrets in demo:         "; kubectl auth can-i list secrets     -n demo --as=$SA
echo -n "delete pods in demo:          "; kubectl auth can-i delete pods      -n demo --as=$SA
echo -n "create pods in demo:          "; kubectl auth can-i create pods      -n demo --as=$SA
echo -n "list pods in kube-system:     "; kubectl auth can-i list pods        -n kube-system --as=$SA
echo -n "list nodes (cluster-scoped):  "; kubectl auth can-i list nodes       --as=$SA
echo -n "create rolebindings in demo:  "; kubectl auth can-i create rolebindings -n demo --as=$SA

echo ""
echo "=== Full permission list for this identity ==="
kubectl auth can-i --list -n demo --as=$SA
