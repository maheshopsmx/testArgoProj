#! /bin/bash

namespace=$1



usage='error: Usage: ./createscaledobject.sh namespace ingressservice'

if [ -z $namespace ]; then echo $usage; exit 1; fi
echo "Checking if namespace exists..."
kubectl get ns $namespace 

if [ $? != 0 ]
then
echo ERROR: namespace $namespace not found, Provide correct namespace;
exit 1
fi
echo "Checking if ingress exists..."
kubectl -n $namespace get ing  -o name > ing.txt
if [ ! -s ing.txt ]; then echo error: no ingresses found in namespace $namespace; exit 1 ; fi

rm -rf "$namespace"-scaledobject.yaml

echo "Getting the deployements..."
kubectl -n "$namespace" get deploy -o name  | grep deployment | sed 's/\// /' | awk '{print $2}' > deploys.txt
if [ ! -s deploys.txt ]
then 
  echo error: no deployments found in namespace $namespace 
else
  while read deployment
  do
    echo "Creating scaledobject for $deployment ..."
    sed  "s/DEPLOYMENT-NAME/$deployment/g" deployment-scaledobject-template.yaml >> "$namespace"-scaledobject.yaml
    sed -i "s/NAMESPACE/$namespace/g" "$namespace"-scaledobject.yaml
    echo '---' >> "$namespace"-scaledobject.yaml
  done < deploys.txt
  rm -rf deploys.txt
fi

echo "Getting the statefulset..."
kubectl -n "$namespace" get sts -o name  | grep statefulset | sed 's/\// /' | awk '{print $2}' > sts.txt
if [ ! -s sts.txt ]
then 
  echo error: no statefulset found in namespace $namespace
else
  while read sts
  do
    echo "Creating scaledobject for $sts ..."
    sed  "s/STS-NAME/$sts/g" sts-scaledobject-template.yaml >> "$namespace"-scaledobject.yaml
    sed -i "s/NAMESPACE/$namespace/g" "$namespace"-scaledobject.yaml
    echo '---' >> "$namespace"-scaledobject.yaml
  done < sts.txt
  rm -rf sts.txt
fi

rm -rf ing.txt

echo 

echo "Please run kubectl apply -f "$namespace"-scaledobject.yaml"
