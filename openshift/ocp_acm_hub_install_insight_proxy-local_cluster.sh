#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/RedHatInsights/insights-proxy-addon.git"
REPO_DIR="${HOME}/insights-proxy-addon"
MANAGED_CLUSTER_NAME="local-cluster"
IMAGE="insights-proxy/insights-proxy-container-rhel9:1.5.3"

info()  { printf '\033[1;34m%s\033[0m\n' "$*"; }
warn()  { printf '\033[1;33m%s\033[0m\n' "$*"; }
error() { printf '\033[1;31m%s\033[0m\n' "$*"; exit 1; }

# ------------------------------
# Prereqs
# ------------------------------

command -v oc >/dev/null || error "oc CLI is required"
command -v git >/dev/null || error "git is required"

oc whoami >/dev/null || error "You must be logged into the OpenShift cluster (oc login)"

# ------------------------------
# Clone or update repo
# ------------------------------

info "Cloning/updating $REPO_URL into $REPO_DIR"

if [[ -d "$REPO_DIR/.git" ]]; then
    git -C "$REPO_DIR" fetch --quiet origin
    git -C "$REPO_DIR" reset --hard origin/master
else
    git clone --depth=1 "$REPO_URL" "$REPO_DIR"
fi

cd "$REPO_DIR"

# ------------------------------
# ManagedCluster resource (same cluster)
# ------------------------------

info "Ensuring ManagedCluster '$MANAGED_CLUSTER_NAME' exists (same cluster used as hub & managed)..."

if ! oc get managedcluster "$MANAGED_CLUSTER_NAME" >/dev/null 2>&1; then
cat <<EOF | oc apply -f -
apiVersion: cluster.open-cluster-management.io/v1
kind: ManagedCluster
metadata:
  name: $MANAGED_CLUSTER_NAME
  labels:
    cloud: auto-detect
    vendor: OpenShift
    should-use-insights-proxy: "true"
spec:
  hubAcceptsClient: true
EOF
else
    info "ManagedCluster already exists"
    oc label managedcluster "$MANAGED_CLUSTER_NAME" should-use-insights-proxy=true --overwrite
fi

# Accept CSR if needed
info "Accepting pending CSR(s) for ManagedCluster..."
for csr in $(oc get csr --no-headers | grep Pending | awk '{print $1}'); do
    oc adm certificate approve "$csr" || true
done

# ------------------------------
# Enable required ACM addons
# ------------------------------

info "Enabling addons on ManagedCluster..."

cat <<EOF | oc apply -f -
apiVersion: addon.open-cluster-management.io/v1alpha1
kind: ManagedClusterAddOn
metadata:
  name: governance-policy-framework
  namespace: $MANAGED_CLUSTER_NAME
spec: {}
EOF

cat <<EOF | oc apply -f -
apiVersion: addon.open-cluster-management.io/v1alpha1
kind: ManagedClusterAddOn
metadata:
  name: config-policy-controller
  namespace: $MANAGED_CLUSTER_NAME
spec: {}
EOF

# ------------------------------
# Import image into local cluster
# ------------------------------

info "Importing image (local cluster acts as hub)..."

set +e
oc import-image "$IMAGE" --from="registry.redhat.io/$IMAGE" --confirm
RC=$?
set -e

if [[ $RC -ne 0 ]]; then
    warn "Image import failed — your cluster may need registry.redhat.io auth"
fi

# ------------------------------
# Deploy resources
# ------------------------------

info "Creating namespace insights-proxy (if missing)..."
oc get ns insights-proxy >/dev/null 2>&1 || oc create ns insights-proxy

info "Applying deploy/ manifests..."
oc apply -f deploy/

# ------------------------------
# Done
# ------------------------------

info "Installation complete on a single OCP cluster acting as hub + managed."

cat <<EOF

Next checks:

1. Check Insights Proxy deployment (hub side — same cluster)
   oc get pods -n insights-proxy

2. Check Insights Operator (managed side — same cluster)
   oc get pods -n openshift-insights

3. Verify operator logs:
   oc logs -n openshift-insights <insights-operator-pod>

If you want, I can also generate:
- an uninstall script
- a debug script for CSR / addon status
- a version-pinning config
EOF

