rm -rf allyamls.txt deploys.txt services.txt
find . -type f  -name "*ml"  > allyamls.txt

while read yamlfile
do
echo checking file $yamlfile
 #yq -i -r '.spec.replicas = 0' $yamlfile
if [ $(yq -r '.kind' $yamlfile )  == Deployment ]
then
echo $yamlfile is a deployment yaml
echo changing replicas to zero in $yamlfile 
yq -i -r '.spec.replicas = 0' $yamlfile
echo number of replicas in $yamlfile $(yq -r '.spec.replicas' $yamlfile)
deployname=$(yq -r '.metadata.name' $yamlfile)
echo creating rollout for this deployment $deployname
cp rollout.tmpl "$deployname"-rollout.yaml
sed -i "s/DEPLOY-NAME/$deployname/g" "$deployname"-rollout.yaml
echo $yamlfile >>deploys.txt
echo creating analysis template for this deployment $deployname
cp analysis.tmpl "$deployname"-at.yaml
labelappname=$(yq -r '.metadata.selector.matchLabels.app' $yamlfile)
sed -i "s/DEPLOY-NAME/$deployname/g" "$deployname"-at.yaml
sed -i "s/APP-LABEL/$labelappname/g" "$deployname"-at.yaml
fi
if [ $(yq -r '.kind' $yamlfile )  == Service ]
then
echo $yamlfile is a service yaml
if echo $yamlfile | grep -v stable | grep -v preview
then
     echo $yamlfile >>services.txt
fi
fi
done < allyamls.txt

echo
echo
echo
while read deploy
do
yq -r '.spec.selector.matchLabels' $deploy > temp-deploy.txt
cat temp-deploy.txt
deployname=$(yq -r '.metadata.name' $deploy)

    while read service
    do
    yq -r '.spec.selector' $service > temp-service.txt
    cat temp-service.txt
    diff temp-deploy.txt temp-service.txt
    if [ $? == 0 ]
    then 
    echo $service corresponds to $deploy
    servicename=$(yq -r '.metadata.name' $service)
    sed -i "s/SERVICE-NAME/$servicename/g" "$deployname"-rollout.yaml
         while read line 
          do echo $line is used for selector;
          key=$(echo $line | awk '{print $1}'| sed 's/://')
          echo $key is the key
          value=$(echo $line | awk '{print $2}')
          value='"'$value'"'
          echo $value is the value
          cmd="yq -i '.spec.selector.matchLabels.${key} = ${value}' "$deployname"-rollout.yaml"
          eval $cmd
          done < temp-service.txt
    break
    fi
    done < services.txt
done < deploys.txt

    while read service
    do
    echo creating preview and stable services
        servicename=$(yq -r '.metadata.name' $service)
    cp $service "$servicename"-stable.yaml
    stablename="$servicename"-stable
    stablename='"'$stablename'"'
    cmd="yq -i '.metadata.name = ${stablename}' "$servicename"-stable.yaml"
              eval $cmd
    cp $service "$servicename"-preview.yaml
    previewname="$servicename"-preview
    previewname='"'$previewname'"'
    cmd="yq -i '.metadata.name = ${previewname}' "$servicename"-preview.yaml"
              eval $cmd
    
    done < services.txt







