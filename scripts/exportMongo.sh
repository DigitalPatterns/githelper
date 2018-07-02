#!/usr/bin/env bash
set -x

mkdir -p /tmp/forms
cd /tmp
for COLLECTION in roles actions forms schema submissions
do
  mongoexport --db admin --collection ${COLLECTION} --out /tmp/forms/${COLLECTION}.json
done
tar zcvf forms.tar.gz forms/
rm -rf forms
