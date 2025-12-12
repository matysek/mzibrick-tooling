#!/usr/bin/env bash
set -euo pipefail

LOCAL_CLUSTER_NAME="local-cluster"

echo ">>> Creating ManagedCluster (${LOCAL_CLUSTER_NAME})"
cat <<EOF | oc apply -f -
apiVersion: cluster.open-cluster-management.io/v1
kind: ManagedCluster
metadata:
  name: ${LOCAL_CLUSTER_NAME}
  labels:
    cloud: auto-detect
    vendor: auto-detect
spec:
  hubAcceptsClient: true
  managedClusterClientConfiguration:
    url: https://kubernetes.default.svc
EOF

echo ">>> Creating KlusterletAddonConfig"
cat <<EOF | oc apply -f -
apiVersion: agent.open-cluster-management.io/v1
kind: KlusterletAddonConfig
metadata:
  name: ${LOCAL_CLUSTER_NAME}
  namespace: ${LOCAL_CLUSTER_NAME}
spec:
  clusterName: ${LOCAL_CLUSTER_NAME}
  clusterNamespace: ${LOCAL_CLUSTER_NAME}
  clusterLabels:
    cloud: auto-detect
    vendor: auto-detect
  applicationManager:
    enabled: true
  policyController:
    enabled: true
  searchCollector:
    enabled: true
  certPolicyController:
    enabled: true
  iamPolicyController:
    enabled: true
EOF

echo ">>> Approving pending CSRs for local cluster"
for csr in $(oc get csr | grep Pending | awk '{print $1}'); do
  echo "  - Approving $csr"
  oc adm certificate approve "$csr"
done

echo ">>> Waiting for managed cluster to become AVAILABLE"
until oc get managedcluster "${LOCAL_CLUSTER_NAME}" \
  -o jsonpath='{.status.conditions[?(@.type=="ManagedClusterConditionAvailable")].status}' \
  | grep True >/dev/null 2>&1; do
  echo "  - Waiting..."
  sleep 10
done

echo ">>> Local cluster successfully imported into ACM!"
echo ">>> Check with:"
echo "    oc get managedcluster ${LOCAL_CLUSTER_NAME}"

