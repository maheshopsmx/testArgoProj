#! /bin/bash

namespace=$1

usage='error: Usage: ./createscaledobject.sh namespace ingressservice'

if [ -z $namespace ]; then echo $usage; exit 1; fi

rm -rf "$namespace"-scaledobject.yaml

kubectl -n "$namespace" get deploy -o name  | grep deployment | sed 's/\// /' | awk '{print $2}' > deploys.txt

while read deployment
do
  sed  "s/DEPLOYMENT-NAME/$deployment/g" deployment-scaledobject-template.yaml >> "$namespace"-scaledobject.yaml
  sed -i "s/NAMESPACE/$namespace/g" "$namespace"-scaledobject.yaml
echo '---' >> "$namespace"-scaledobject.yaml
done < deploys.txt

kubectl -n "$namespace" get sts -o name  | grep statefulset | sed 's/\// /' | awk '{print $2}' > sts.txt

while read sts
do
  sed  "s/STS-NAME/$sts/g" sts-scaledobject-template.yaml >> "$namespace"-scaledobject.yaml
  sed -i "s/NAMESPACE/$namespace/g" "$namespace"-scaledobject.yaml
  echo '---' >> "$namespace"-scaledobject.yaml
done < sts.txt
