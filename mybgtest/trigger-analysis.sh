#!/bin/bash
rons=$1
if [ -z $rons ]; then echo 'error: Usage: ./trigger-analysis.sh <namespace-in-which-rollout-andtemplate-were-deployed' ; exit 1; fi
git rev-parse --is-inside-work-tree

if [ $? != 0 ]
then
echo this command must be run inside the folder which is part of github repo which was used to deploy to argocd; 
exit 1
fi

if [ ! -f rollout.yaml ]
then
    echo "File rollout.yaml does not exist , are you sure you are running in the right folder"
    exit 1
fi

ingithubimage=$( cat rollout.yaml | grep image: | head -1 | awk '{print $NF}')

inroimage=$( kubectl -n $rons get rollout multins-bg -o jsonpath='{.spec.template.spec.containers[0].image}')
if [ -z $inroimage ]; then echo 'error: could find rollout multins-bg, are you sure you are using the right namespace'  ; exit 1; fi

echo docker.io/opsmxdev/issuegen:v3.0.6 >images.txt
echo docker.io/opsmxdev/issuegen:v3.0.7 >>images.txt
echo docker.io/opsmxdev/issuegen:v3.0.8 >>images.txt

newimage=$(cat images.txt | grep -v $inroimage | grep -v $ingithubimage| head -1)

echo $newimage

sed -i "s#$inroimage#$newimage#" rollout.yaml

rm -rf images.txt

git add rollout.yaml
git commit -m " new image added to rollout $newimage"
git push
