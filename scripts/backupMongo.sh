#!/usr/bin/env bash

export KUBECTL_NAMESPACE="${KUBECTL_NAMESPACE:-bfarch-dev}"
export FORMIO_DEPLOYMENT_NAME="${FORMIO_DEPLOYMENT_NAME}:-formio"
export MONGO_CONTAINER_NAME="${MONGO_CONTAINER_NAME}:-mongo"
export FORMIO_POD=$(kubectl --namespace ${KUBECTL_NAMESPACE} get pods | grep ${FORMIO_DEPLOYMENT_NAME} | cut -f 1 -d " ")

kubectl cp /bin/exportMongo.sh ${KUBECTL_NAMESPACE}/${FORMIO_POD}:/tmp/exportMongo.sh --container ${MONGO_CONTAINER_NAME}
kubectl --namespace ${KUBECTL_NAMESPACE} exec -it ${FORMIO_POD} --container ${MONGO_CONTAINER_NAME} '/bin/bash -c "chmod +x /tmp/exportMongo.sh; /tmp/exportMongo.sh"'

cd /repo
kubectl cp ${KUBECTL_NAMESPACE}/${FORMIO_POD}:/tmp/forms.tar.gz forms.tar.gz --container ${MONGO_CONTAINER_NAME}
tar zxvf forms.tar.gz
git commit -a forms/* -c "Auto Mongo FormIO Backup"
git push origin backup
kubectl --namespace ${KUBECTL_NAMESPACE} exec -it ${FORMIO_POD} --container ${MONGO_CONTAINER_NAME} "rm /tmp/forms.tar.gz"
