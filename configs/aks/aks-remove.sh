#bin/bash
set -e 

clusterName="aks-pick"
resourceGroup="rg-dev-pick"
location="eastus"


az account set -s "609695b4-9130-4327-a014-cc8e212d806f"

az group delete --name $resourceGroup --force-deletion-types Microsoft.Compute/virtualMachineScaleSets --yes --no-wait
