#!/bin/bash
app=$1
pns=$2
isdns=$3
usage='error: Usage: ./automate-trigger.sh applicationname preview-namespace isd-namespace'

if [ -z $app ]; then echo $usage; exit 1; fi
if [ -z $pns ]; then  echo $usage; exit 1; fi

kubectl -n $isdns get application $app

if [ $? != 0 ]
then
echo application $app not found, please give correct namespace of isd and correct applicationName; 
exit 1
fi

path=$( kubectl -n $isdns get application rajuapp -o jsonpath='{.spec.source.path}')
$gitrepo=$(  kubectl -n $isdns get application rajuapp -o jsonpath='{.spec.source.repoURL}')
$gitrevision=$( kubectl -n $isdns get application rajuapp -o jsonpath='{.spec.source.targetRevision}')

sed "s#APP-NAME#$app#g" trigger-job.yaml > autotrigger.yaml
sed -i "s#GIT-REPO#$gitrepo#g" autotrigger.yaml
sed -i "s#GIT-BRANCH#$gitrevision#g" autotrigger.yaml

sed -i "s#PREVIEW-NS#$gitrevision#g" autotrigger.yaml

echo 

echo  commit the created file autotrigger.yaml into the github repo, in the same folder as where the preview application yamls are present
echo  go to argocd ui and sync the preview application.
echo go to the argocd ui and sync the analysis application <applicationName> , check if an analysis is triggered




