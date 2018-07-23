#!/bin/bash

set -x

/bin/clone.sh

mongod --config /config/mongod.conf > /dev/null &

mongoimport --db admin --drop --collection actions --file /repo/forms/actions.json
mongoimport --db admin --drop --collection forms --file /repo/forms/forms.json
mongoimport --db admin --drop --collection roles --file /repo/forms/roles.json
mongoimport --db admin --drop --collection schema --file /repo/forms/schema.json
mongoimport --db admin --drop --collection submissions --file /repo/forms/submissions.json

mongo admin --eval '{ db.shutdownServer() };'
