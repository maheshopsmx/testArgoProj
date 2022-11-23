#!/bin/bash
appns=$1

mkdir -p $appns
cd $appns

#get deploys

kubectl -n $appns get deploy -o name > deploys.txt

echo please edit "$appns"/deploys.txt and delete lines for which you do not plan analysis


