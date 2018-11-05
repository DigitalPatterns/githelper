#!/usr/bin/env bash

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

if [[ ! -f "/home/${USER}/.ssh/id_rsa" ]]
then
  echo ${PRIVATE_KEY} | base64 -d > /home/${USER}/.ssh/id_rsa
  chmod 400 /home/${USER}/.ssh/id_rsa
  touch /home/${USER}/.ssh/known_hosts
  /bin/gethost.py "${REPO_URL}"
fi 

cd /repo
git pull

if (($? > 0))
then
  printf '%s\n' 'GIT Checkout Error!' >&2
  exit 2
fi
