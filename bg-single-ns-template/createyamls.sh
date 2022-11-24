#!/bin/bash
appns=$1

echo creating yamls from templates

while read servicename
do 
echo $servicename
done < $appns/deploys.txt