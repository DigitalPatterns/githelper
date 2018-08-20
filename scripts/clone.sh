#!/usr/bin/env bash

set -x

export USER=$(whoami)

if [[ ! ${USER} -eq "root" ]]
then
  export HOME="/home/${USER}"
else
  export HOME="/tmp"
fi

echo ${PRIVATE_KEY}

echo ${PRIVATE_KEY} | base64 -d > /home/${USER}/.ssh/id_rsa
chmod 400 /home/${USER}/.ssh/id_rsa

touch /home/${USER}/.ssh/known_hosts

/bin/gethost.py ${REPO_URL}

echo ${REPO_URL}

git clone ${REPO_URL} /repo
cd /repo
ls -la
cat .git/config

git fetch --all --tags --prune

if [[ ! -z  ${GIT_TAG} ]]
then
    git show-ref --tags | egrep -q "refs/tags/${GIT_TAG}"
    TAG_EXIT = $?
    git show-ref --heads | egrep -q "refs/heads/${GIT_TAG}"
    BRANCH_EXIT = $?
    if [[ ${TAG_EXIT} -eq 0 ]]
    then
        git checkout tags/${GIT_TAG}
        if [[ $1 -ne 0 ]]
        then
            echo "Error checking out tag ${GIT_TAG}"
            exit 2
        fi
    elif [[ ${BRANCH_EXIT} -eq 0 ]]
    then
        git checkout ${GIT_TAG}
        if [[ $1 -ne 0 ]]
        then
            echo "Error checking out branch ${GIT_TAG}"
            exit 2
        fi
    else
        echo "TAG or Branch not found: ${GIT_TAG}"
        exit 1
    fi
else
    echo "TAG or Branch not set"
    exit 1
fi

ls /repo

if (($? > 0))
then
  printf '%s\n' 'GIT Checkout Error!' >&2
  exit 2
fi
