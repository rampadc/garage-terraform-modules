#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname $0); pwd -P)
MODULE_DIR=$(cd ${SCRIPT_DIR}/..; pwd -P)

NAMESPACE="$1"

echo "*** deleting Prometheus operator in target namespace.." 
YAML_FILE=${MODULE_DIR}/yaml/prometheus-operator.yaml
oc delete -f ${YAML_FILE} -n ${NAMESPACE} || true

sleep 10
echo '>>> Prometheus operator in target namespace is deleted'

echo "*** deleting target namespace for monitoring tools stack.."
oc delete project "${NAMESPACE}" 1> /dev/null 2> /dev/null || true
echo '>>> monoring tools namespace is deleted'
