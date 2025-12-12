#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="open-cluster-management"
CHANNEL="release-2.14"      # <-- change to the ACM version channel you need
SOURCE="redhat-operators"
SOURCE_NS="openshift-marketplace"

echo ">>> Creating namespace: $NAMESPACE"
oc create namespace "$NAMESPACE" 2>/dev/null || echo "Namespace already exists"

echo ">>> Creating OperatorGroup"
cat <<EOF | oc apply -f -
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: acm-operator
  namespace: ${NAMESPACE}
spec:
  targetNamespaces:
  - ${NAMESPACE}
EOF

echo ">>> Creating Subscription for ACM operator"
cat <<EOF | oc apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: acm-operator-subscription
  namespace: ${NAMESPACE}
spec:
  channel: ${CHANNEL}
  name: advanced-cluster-management
  source: ${SOURCE}
  sourceNamespace: ${SOURCE_NS}
  installPlanApproval: Automatic
EOF

echo ">>> Waiting for ACM operator to be installed..."
until oc get csv -n "$NAMESPACE" | grep advanced-cluster-management | grep Succeeded; do
  echo "  - Waiting for operator CSV to reach Succeeded..."
  sleep 10
done

echo ">>> Creating MultiClusterHub CR"
cat <<EOF | oc apply -f -
apiVersion: operator.open-cluster-management.io/v1
kind: MultiClusterHub
metadata:
  name: multiclusterhub
  namespace: ${NAMESPACE}
spec: {}
EOF

echo ">>> ACM installation triggered."
echo ">>> Check status with:"
echo "    oc get pods -n ${NAMESPACE}"
echo "    oc get multiclusterhub -n ${NAMESPACE}"

