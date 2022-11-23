#!/bin/bash
appns=$1

echo creating yamls from templates

while read line
do 
echo $line
done < $appns/deploys.txt