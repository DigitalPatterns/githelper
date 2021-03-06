#!/usr/bin/env bash
set -x

if [[ ! -z "${MONGO_DBNAME}" ]]
then
    echo "${MONGO_DBNAME}"
else
    export MONGO_DBNAME="admin"
fi

mkdir -p /tmp/forms
cd /tmp
for COLLECTION in roles actions forms schema submissions
do
  mongoexport --db ${MONGO_DBNAME} --collection ${COLLECTION} --out /tmp/forms/${COLLECTION}.json
done
tar zcvf forms.tar.gz forms/
rm -rf forms
