#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname $0); pwd -P)

ACCESS_KEY="$1"
ENDPOINT="$2"
NAMESPACE="$3"

if [[ -n "${KUBECONFIG_IKS}" ]]; then
   export KUBECONFIG="${KUBECONFIG_IKS}"
else
   OPENSHIFT="-op"
fi

echo "*** Binding sysdig to cluster namespace ${NAMESPACE} using endpoint: ${ENDPOINT}"

#curl -sL https://ibm.biz/install-sysdig-k8s-agent | \
#  bash -s -- -a "${ACCESS_KEY}" -c "${ENDPOINT}" -ns "${NAMESPACE}" ${OPENSHIFT} -ac 'sysdig_capture_enabled: false'

cat ${SCRIPT_DIR}/install-agent-k8s.sh | \
  bash -s -- -a "${ACCESS_KEY}" -c "${ENDPOINT}" -ns "${NAMESPACE}" ${OPENSHIFT} -ac 'sysdig_capture_enabled: false'
