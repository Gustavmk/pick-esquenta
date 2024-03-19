#bin/bash
set -e 

clusterName="aks-pick"
resourceGroup="rg-dev-pick"
location="eastus"

#VNET
vnet="vnet-aks-pick"

# AKS
AKS_POD_CIDR='192.168.0.0/16'
AKS_SIZE_POOL_DEFAULT="Standard_B4s_v2"

az account set -s "609695b4-9130-4327-a014-cc8e212d806f"

# Create the resource group
az group create --name $resourceGroup --location $location

# Create our two subnet network 
az network vnet create --resource-group $resourceGroup --location $location --name $vnet --address-prefixes 10.0.0.0/8 -o none 
az network vnet subnet create --resource-group $resourceGroup --vnet-name $vnet --name aks-pool-default --address-prefixes 10.240.0.0/16 -o none 
az network vnet subnet create --resource-group $resourceGroup --vnet-name $vnet --name podsubnet --address-prefixes 10.241.0.0/16 -o none

# Run the Azure CLI command and store the output in a variable
GET_VERSION=$(az aks get-versions --location eastus --output table)

# Use grep to find the first non-preview Kubernetes version
AKS_K8S_VERSION=$(echo "$GET_VERSION" | grep -E '^[0-9]+\.[0-9]+\.[0-9]+' | grep -v True | head -n 1 | awk '{print $1}')


az aks create --resource-group $resourceGroup --location $location --name $clusterName --network-plugin "azure" --network-plugin-mode "overlay" --network-dataplane "azure" --pod-cidr $AKS_POD_CIDR --generate-ssh-keys --kubernetes-version $AKS_K8S_VERSION --node-vm-size "$AKS_SIZE_POOL_DEFAULT" --vnet-subnet-id "/subscriptions/609695b4-9130-4327-a014-cc8e212d806f/resourceGroups/rg-dev-pick/providers/Microsoft.Network/virtualNetworks/vnet-aks-pick/subnets/aks-pool-default"