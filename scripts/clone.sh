#!/usr/bin/env bash

set -x

export USER=$(whoami)

if [[ ! ${USER} -eq "root" ]]
then
  export HOME="/home/${USER}"
else
  export HOME="/tmp"
fi

echo ${PRIVATE_KEY} | base64 -d > /home/${USER}/.ssh/id_rsa
chmod 400 /home/${USER}/.ssh/id_rsa

touch /home/${USER}/.ssh/known_hosts

/bin/gethost.py ${REPO_URL}

git clone ${REPO_URL} /repo
cd /repo
git fetch --all --tags --prune

if [[ ! -z  ${GIT_TAG} ]]
then
  if [[ ! ${GIT_TAG} == "master" ]]
  then
    git checkout tags/${GIT_TAG}
   fi
else
  git checkout backup
fi

ls /repo

if (($? > 0))
then
  printf '%s\n' 'GIT Checkout Error!' >&2
  exit 2
fi
