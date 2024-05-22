SP_NAME="sp-deployment"
SCOPE_SUBSCRITPION=$(echo $AZ_SUBSCRIPTION_ID)
ROLE="contributor"

az ad sp create-for-rbac --name $SP_NAME --role $ROLE --scopes "/subscriptions/${SCOPE_SUBSCRITPION}"


# get service principals using an OData filter
az ad sp list --filter "displayname eq '$SP_NAME'" --output json


#newPassword=$(az ad sp credential reset --id $SP_NAME --query password --output tsv)
#echo $newPassword