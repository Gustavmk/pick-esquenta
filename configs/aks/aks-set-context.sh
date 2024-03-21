#bin/bash
set -e 

clusterName="aks-pick"
resourceGroup="rg-dev-pick"
AZ_SUBSCRIPTION='609695b4-9130-4327-a014-cc8e212d806f'

az account set -s $AZ_SUBSCRIPTION

az aks get-credentials --admin --name $clusterName --resource-group $resourceGroup --overwrite-existing