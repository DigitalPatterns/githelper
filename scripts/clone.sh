#!/usr/bin/env bash

echo ${PRIVATE_KEY} | base64 -d > /home/${USER}/.ssh/id_rsa
chmod 400 /home/${USER}/.ssh/id_rsa

touch /home/${USER}/.ssh/known_hosts

/bin/gethost.py ${REPO_URL}

git clone ${REPO_URL} /repo
cd /repo
git fetch --all --tags --prune

if [[ ! -z  ${GIT_TAG} ]]
then
  git checkout tags/${GIT_TAG}
else
  git checkout backup
fi

if (($? > 0))
then
  printf '%s\n' 'GIT Checkout Error!' >&2
  exit 2
fi
