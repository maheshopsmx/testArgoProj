find . -type f  | xargs grep 'kind: Deployment' | sed 's/:kind: Deployment//' > deploys.txt

while read deployment
do
echo changinf to 0 replicas in $deployment
 yq -i -r '.spec.replicas = 0' $deployment
done < deploys.txt


