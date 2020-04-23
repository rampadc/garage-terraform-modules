#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname $0); pwd -P)
CHART_DIR=$(cd "${SCRIPT_DIR}/../charts"; pwd -P)

TOOLS_NAMESPACE="$1"
SERVER_URL="$2"

if [[ -z "${TMP_DIR}" ]]; then
  TMP_DIR=./tmp
fi

mkdir -p ${TMP_DIR}

YAML_OUTPUT=${TMP_DIR}/jenkins-config.yaml
PIPELINE_URL="${SERVER_URL}/console/projects"

helm template "${CHART_DIR}/pipeline-config" \
    --name "pipeline-config" \
    --namespace "${TOOLS_NAMESPACE}" \
    --set "pipeline.url=${PIPELINE_URL}" \
    --set "pipeline.tls=true" > ${YAML_OUTPUT}
kubectl apply --namespace "${TOOLS_NAMESPACE}" -f ${YAML_OUTPUT}
