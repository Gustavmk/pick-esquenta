#bin/bash
set -e 

clusterName="aks-pick"
resourceGroup="rg-dev-pick"
AZ_SUBSCRIPTION='0ee6a046-0e26-40b7-a327-8bb4f285dd69'

az account set -s $AZ_SUBSCRIPTION

az aks get-credentials --admin --name $clusterName --resource-group $resourceGroup --overwrite-existing