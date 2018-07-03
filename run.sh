#!/usr/bin/env bash


export PRIVATE_KEY="${PRIVATE_KEY}"
export REPO_URL="${REPO_URL}"
export KUBECTL_TOKEN="${KUBECTL_TOKEN}"
export KUBECTL_SERVER="${KUBECTL_SERVER}"

if [[ -z ${REPO_URL} ]]
then
  echo "REPO_URL missing"
  exit 1
fi

if [[ -z ${PRIVATE_KEY} ]]
then
  echo "PRIVATE_KEY missing"
  exit 1
fi

if [[ -z ${KUBECTL_TOKEN} ]]
then
  echo "KUBECTL_TOKEN missing"
  exit 1
fi

if [[ -z ${KUBECTL_SERVER} ]]
then
  echo "KUBECTL_SERVER missing"
  exit 1
fi

docker run -it -e PRIVATE_KEY=${PRIVATE_KEY} -e REPO_URL=${REPO_URL} -e KUBECTL_TOKEN=${KUBECTL_TOKEN} -e KUBECTL_SERVER=${KUBECTL_SERVER} quay.io/ukhomeofficedigital/githelper:latest bash