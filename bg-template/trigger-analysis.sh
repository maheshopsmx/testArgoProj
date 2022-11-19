#!/bin/bash
cd /tmp
inroimage=$( kubectl -n multins-bg get rollout multins-bg -o jsonpath='{.spec.template.spec.containers[0].image}')
inpodimage=$( kubectl -n multins-bg get po -o yaml | grep image: | head -1 | awk '{print $NF}')

#ingithubimage=docker.io/opsmxdev/issuegen:v3.0.8

echo docker.io/opsmxdev/issuegen:v3.0.6 >images.txt
echo docker.io/opsmxdev/issuegen:v3.0.7 >>images.txt
echo docker.io/opsmxdev/issuegen:v3.0.8 >>images.txt

newimage=$(cat images.txt | grep -v $inroimage | grep -v $inpodimage| head -1)

echo $newimage

kubectl -n multins-bg get rollout multins-bg -o yaml > rollout.yaml

sed -i "s#$inroimage#$newimage#" rollout.yaml
kubectl apply -f rollout.yaml