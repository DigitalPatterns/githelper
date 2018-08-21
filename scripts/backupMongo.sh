#!/usr/bin/env bash
echo "Running Backup script"

if [[ ! -z "${DEBUG}" ]]
then
    set -x
fi

export USER=$(whoami)

if [[ ! ${USER} -eq "root" ]]
then
  export HOME="/home/${USER}"
else
  export HOME="/tmp"
fi

if [[ ! -z "${MONGO_DBNAME}" ]]
then
    echo "${MONGO_DBNAME}"
else
    export MONGO_DBNAME="admin"
fi

mkdir -p ${HOME}/.kube
export KUBECTL_NAMESPACE="${KUBECTL_NAMESPACE:-bfarch-dev}"
export FORMIO_DEPLOYMENT_NAME="${FORMIO_DEPLOYMENT_NAME:-formio}"
export MONGO_CONTAINER_NAME="${MONGO_CONTAINER_NAME:-mongo}"
export REPO_URL="${REPO_URL}"
export KUBECTL_SERVER="${KUBECTL_SERVER}"
export k="kubectl --server ${KUBECTL_SERVER} --token ${KUBECTL_TOKEN} --insecure-skip-tls-verify=true"
export FORMIO_POD=$($k --namespace ${KUBECTL_NAMESPACE} get pods | grep ${FORMIO_DEPLOYMENT_NAME} | cut -f 1 -d " ")
export GIT_TAG="${GIT_TAG:-backup}"

echo ${PRIVATE_KEY} | base64 -d > /home/${USER}/.ssh/id_rsa
chmod 400 /home/${USER}/.ssh/id_rsa
touch /home/${USER}/.ssh/known_hosts
/bin/gethost.py ${REPO_URL}

git clone ${REPO_URL} /repo
if [[ $? -ne 0 ]]
then
    echo "GIT Clone Error"
    exit 1
fi

cd /repo
export REFS=$(git show-ref)

if [[ ! -z "${GIT_TAG}" ]]
then
    echo ${REFS} | egrep -q "refs/remotes/origin/${GIT_TAG}"
    BRANCH_EXIT=$?
    if [[ ${BRANCH_EXIT} -eq 0 ]]
    then
        git checkout ${GIT_TAG}
        if [[ $1 -ne 0 ]]
        then
            echo "Error checking out branch ${GIT_TAG}"
            exit 2
        fi
    else
        echo "Branch not found: ${GIT_TAG}"
        exit 1
    fi
else
    echo "Branch not set"
    exit 1
fi

git branch

$k cp /bin/exportMongo.sh ${KUBECTL_NAMESPACE}/${FORMIO_POD}:/tmp/exportMongo.sh --container ${MONGO_CONTAINER_NAME}
$k --namespace ${KUBECTL_NAMESPACE} exec -it ${FORMIO_POD} --container ${MONGO_CONTAINER_NAME} -- /bin/bash -c "chmod +x /tmp/exportMongo.sh; export MONGO_DBNAME=${MONGO_DBNAME} /tmp/exportMongo.sh"

cd /repo
$k cp ${KUBECTL_NAMESPACE}/${FORMIO_POD}:/tmp/forms.tar.gz forms.tar.gz --container ${MONGO_CONTAINER_NAME}
tar zxvf forms.tar.gz
git config user.email "backup@docker.service"
git config user.name "Backup Mongo"
git add forms/*.json
git commit -m "Auto Mongo FormIO Backup"
git push

$k --namespace ${KUBECTL_NAMESPACE} exec -it ${FORMIO_POD} --container ${MONGO_CONTAINER_NAME} -- /bin/bash -c "rm /tmp/forms.tar.gz"
