#bin/bash
set -e 

clusterName="aks-pick"
resourceGroup="rg-dev-pick"
location="eastus"


az account set -s $AZ_SUBSCRIPTION_ID

az group delete --name $resourceGroup --force-deletion-types Microsoft.Compute/virtualMachineScaleSets --yes
