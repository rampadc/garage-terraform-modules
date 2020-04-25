#!/usr/bin/env bash

SCC_LIST_DELIM=$(echo "${1}" | sed -E 's/[[](.*)[]]/\1/g' | sed 's/\"//g')

kubectl get serviceaccount "${SERVICE_ACCOUNT_NAME}" -n "${NAMESPACE}"

IFS=',' read -ra SCC_LIST <<< "$SCC_LIST_DELIM"
for scc in "${SCC_LIST[@]}"; do
  kubectl patch scc "${scc}" \
    --type=json \
    -p="[{\"op\": \"add\", \"path\": \"/users/-\", \"value\": \"system:serviceaccount:${NAMESPACE}:${SERVICE_ACCOUNT_NAME}\"}]"
done