#bin/bash
set -e 

clusterName="aks-pick"
resourceGroup="rg-dev-pick"


az account set -s $$AZ_SUBSCRIPTION_ID

az aks get-credentials --admin --name $clusterName --resource-group $resourceGroup --overwrite-existing