#!/bin/bash
git rev-parse --is-inside-work-tree
if [ $? != 0 ]
then
echo error: this command must be run inside the folder which is part of github repo ; 
exit 1
fi
url=https://raw.githubusercontent.com/gopaljayanthi/testArgoProj/main/bg-no-instrumentation-template
curl $url/create.sh -o create.sh
curl $url/rollout.yaml -o rollout.yaml
curl $url/service.yaml -o service.yaml
curl $url/services.txt -o services.txt
curl $url/template.yaml -o template.yaml

curl $url/secret.yaml -o secret.yaml
curl $url/instructions.txt -o instructions.txt
curl $url/application.yaml -o application.yaml

git add -A
git commit -m "adding templates"
git push

echo Please read instructions.txt in folder before running create.sh with required arguments

