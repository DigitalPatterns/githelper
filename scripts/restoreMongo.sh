#!/usr/bin/env bash

set -x
if [[ ! -z "${MONGO_DBNAME}" ]]
then
    echo "${MONGO_DBNAME}"
else
    export MONGO_DBNAME="admin"
fi

/bin/clone.sh
if [[ $? -ne 0 ]]
then
    echo "GIT Error - aborting"
    exit 2
fi

mongod --config /config/mongod.conf > /dev/null &

mongoimport --db ${MONGO_DBNAME} --drop --collection actions --file /repo/forms/actions.json
mongoimport --db ${MONGO_DBNAME} --drop --collection forms --file /repo/forms/forms.json
mongoimport --db ${MONGO_DBNAME} --drop --collection roles --file /repo/forms/roles.json
mongoimport --db ${MONGO_DBNAME} --drop --collection schema --file /repo/forms/schema.json
mongoimport --db ${MONGO_DBNAME} --drop --collection submissions --file /repo/forms/submissions.json

mongo admin --eval '{ db.shutdownServer() };'
