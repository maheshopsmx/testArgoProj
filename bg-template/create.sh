#!/bin/bash
mydir=$1 # a folder and a namespace will be created using this
bns=$2 # baseline namespace
pns=$3 # preview namespace
isdns=$4 # isd namespace
instructions=' error: you need to be connected to the kubernetes cluster to get this script to work '
usage='error: Usage: ./create.sh directoryname baseline-namesapce canary-namespace isd-namespace'

if [ -z $mydir ]; then echo $usage; exit 1; fi
if [ -z $pns ]; then  echo $usage; exit 1; fi
if [ -z $bns ]; then  echo $usage; exit 1; fi
if [ -z $isdns ]; then  echo $usage; exit 1; fi

kubectl version

if [ $? != 0 ]
then
echo $instructions; 
exit 1
fi

echo creating folder $mydir
mkdir -p $mydir
cp *.yaml $mydir
cp services.txt $mydir
cd $mydir 

echo creating rollout

sed -i "s/BASELINE-NAMESPACE/$bns/" rollout.yaml
sed -i "s/PREVIEW-NAMESPACE/$pns/" rollout.yaml

echo creating secret

isdhost=$( kubectl -n $isdns get ing oes-ui-ingress -o jsonpath='{.spec.rules[0].host}')
 if [ -z $isdhost ]; then  echo isd ingress not found, are you sure isd in installed in $isdns; exit 1; fi

sed -i "s#GATE-URL#$isdhost#" secret.yaml

echo creating analysis template

kubectl -n "$bns" get deploy -o name  | grep deployment | sed 's/\// /' | awk '{print $2}' > deploys.txt
 if [ ! -s deploys.txt ]; then echo error: no deployments found in namespace $bns; exit 1 ; fi

kubectl -n "$pns" get deploy -o name  | grep deployment | sed 's/\// /' | awk '{print $2}' > previewdeploys.txt
 if [ ! -s previewdeploys.txt ]; then echo error: no deployments found in namespace $pns; exit 1 ; fi




while read line 
 do 
echo adding service $line to template
sed "s/SERVICENAME/$line/g" services.txt >> template.yaml 
done < deploys.txt

echo Successfully created service, rollout and template yaml files

echo please add $mydir to your github repo and create an argocd application.