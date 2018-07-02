#!/usr/bin/env bash
set -x

export USER=$(whoami)
export KUBECTL_NAMESPACE="${KUBECTL_NAMESPACE:-bfarch-dev}"
export FORMIO_DEPLOYMENT_NAME="${FORMIO_DEPLOYMENT_NAME:-formio}"
export MONGO_CONTAINER_NAME="${MONGO_CONTAINER_NAME:-mongo}"
export REPO_URL="${REPO_URL}"
export KUBECTL_SERVER="${KUBECTL_SERVER}"
export k="kubectl --server ${KUBECTL_SERVER} --token ${KUBECTL_TOKEN} --insecure-skip-tls-verify=true"
export FORMIO_POD=$($k --namespace ${KUBECTL_NAMESPACE} get pods | grep ${FORMIO_DEPLOYMENT_NAME} | cut -f 1 -d " ")

env

clone.sh

$k cp /bin/exportMongo.sh ${KUBECTL_NAMESPACE}/${FORMIO_POD}:/tmp/exportMongo.sh --container ${MONGO_CONTAINER_NAME}
$k --namespace ${KUBECTL_NAMESPACE} exec -it ${FORMIO_POD} --container ${MONGO_CONTAINER_NAME} -- /bin/bash -c "chmod +x /tmp/exportMongo.sh; /tmp/exportMongo.sh"

cd /repo
$k cp ${KUBECTL_NAMESPACE}/${FORMIO_POD}:/tmp/forms.tar.gz forms.tar.gz --container ${MONGO_CONTAINER_NAME}
tar zxvf forms.tar.gz
git commit -a forms/* -c "Auto Mongo FormIO Backup"
git push origin backup

$k --namespace ${KUBECTL_NAMESPACE} exec -it ${FORMIO_POD} --container ${MONGO_CONTAINER_NAME} -- /bin/bash -c "rm /tmp/forms.tar.gz"
