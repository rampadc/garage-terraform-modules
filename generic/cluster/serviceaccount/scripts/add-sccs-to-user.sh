#!/usr/bin/env bash

NAMESPACE="${1}"
SERVICE_ACCOUNT_NAME="${2}"
SCC_JSON_ARRAY="${3}"

if [[ -z "${NAMESPACE}" ]]; then
  echo "Namespace is required as the first parameter"
  exit 1
fi

if [[ -z "${SERVICE_ACCOUNT_NAME}" ]]; then
  echo "Service Account Name is required as the second parameter"
  exit 1
fi

if [[ -z "${SCC_JSON_ARRAY}" ]]; then
  echo "JSON array of SCC names is required as the third parameter"
  exit 1
fi

SCC_LIST_DELIM=$(echo "${SCC_JSON_ARRAY}" | sed -E 's/[[](.*)[]]/\1/g' | sed 's/\"//g')
RETRY_COUNT=2

kubectl get serviceaccount "${SERVICE_ACCOUNT_NAME}" -n "${NAMESPACE}" 1>/dev/null

IFS=',' read -ra SCC_LIST <<< "$SCC_LIST_DELIM"
for scc in "${SCC_LIST[@]}"; do
  count=0

  if [[ -n $(oc get "scc/${scc}" -o jsonpath="{.users[?(@ == \"system:serviceaccount:${NAMESPACE}:${SERVICE_ACCOUNT_NAME}\")]}") ]]; then
    echo ">>> ${NAMESPACE}:${SERVICE_ACCOUNT_NAME} was already added to ${scc} scc"
    continue
  fi

  until kubectl patch scc "${scc}" \
    --type=json \
    -p="[{\"op\": \"add\", \"path\": \"/users/-\", \"value\": \"system:serviceaccount:${NAMESPACE}:${SERVICE_ACCOUNT_NAME}\"}]" 1>/dev/null || \
    [[ $count -eq ${RETRY_COUNT} ]]
  do
      SLEEP_TIME=$(( RANDOM % 20 ))
      echo ">>> Error adding ${scc} scc to ${NAMESPACE}:${SERVICE_ACCOUNT_NAME}. Sleeping ${SLEEP_TIME} seconds before trying again"
      sleep ${SLEEP_TIME}
      count=$((count + 1))
  done

  if [[ $count -eq ${RETRY_COUNT} ]]; then
    echo ">>> Retry count exceeded. Unable to add ${scc} scc to ${NAMESPACE}:${SERVICE_ACCOUNT_NAME}"
    exit 1
  else
    echo ">>> Added ${scc} scc to ${NAMESPACE}:${SERVICE_ACCOUNT_NAME}"
  fi
done