#!/usr/bin/env bash

RESOURCE_GROUP="$1"
REGION="$2"
REGISTRY_URL_FILE="$3"

# The name of a registry namespace cannot contain uppercase characters
# Lowercase the resource group name, just in case...
REGISTRY_NAMESPACE="cong"

ibmcloud login --apikey "${APIKEY}" -g "${RESOURCE_GROUP}" -r "${REGION}" 1> /dev/null 2> /dev/null
if [[ $? -ne 0 ]]; then
  echo "Error logging into ibmcloud"
  exit 1
fi

if [[ "${REGION}" =~ "us-" ]]; then
  REGION="us-south"
elif [[ "${REGION}" == "eu-gb" ]]; then
  REGION="uk-south"
elif [[ "${REGION}" =~ "eu-" ]]; then
  REGION="eu-central"
elif [[ "${REGION}" =~ "jp-" ]]; then
  REGION="ap-north"
elif [[ "${REGION}" =~ "ap-" ]]; then
  REGION="ap-south"
fi

ibmcloud cr region-set "${REGION}"
echo "Checking registry namespace: ${REGISTRY_NAMESPACE}"
NS=$(ibmcloud cr namespaces | grep "${REGISTRY_NAMESPACE}" ||: )
if [[ -z "${NS}" ]]; then
    echo -e "Registry namespace ${REGISTRY_NAMESPACE} not found, creating it."
    ibmcloud cr namespace-add "${REGISTRY_NAMESPACE}"
else
    echo -e "Registry namespace ${REGISTRY_NAMESPACE} found."
fi

REGISTRY_URL=$(ibmcloud cr region | grep "icr.io" | sed -E "s/.*'(.*icr.io)'.*/\1/")
if [[ -n "${REGISTRY_URL_FILE}" ]]; then
  echo -n "${REGISTRY_URL}" > "${REGISTRY_URL_FILE}"
fi
