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

AZ_VNET_ADDRESS_POOL='10.0.0.0/8'
AZ_VNET_SUBNET_POOL_DEFAULT='10.240.0.0/16'

az account set -s $AZ_SUBSCRIPTION_ID

# Create the resource group
echo "Deploying Resource Group"
az group create --name $resourceGroup --location $location

# Create our two subnet network 
echo "Deploying VNET"
az network vnet create --resource-group $resourceGroup --location $location --name $vnet --address-prefixes "${AZ_VNET_ADDRESS_POOL}" -o none 
az network vnet subnet create --resource-group $resourceGroup --vnet-name $vnet --name aks-pool-default --address-prefixes "${AZ_VNET_SUBNET_POOL_DEFAULT}"  -o none 


# Run the Azure CLI command and store the output in a variable
GET_VERSION=$(az aks get-versions --location eastus --output table)

# Use grep to find the first non-preview Kubernetes version
AKS_K8S_VERSION=$(echo "$GET_VERSION" | grep -E '^[0-9]+\.[0-9]+\.[0-9]+' | grep -v True | head -n 1 | awk '{print $1}')

echo "Deploying AKS with version: ${AKS_K8S_VERSION}"
az aks create --node-count 2 --tier free --resource-group $resourceGroup --location $location --name $clusterName --network-plugin "azure" --network-plugin-mode "overlay" --network-dataplane "azure" --pod-cidr $AKS_POD_CIDR --generate-ssh-keys --kubernetes-version $AKS_K8S_VERSION --node-vm-size "$AKS_SIZE_POOL_DEFAULT" --vnet-subnet-id "/subscriptions/$AZ_SUBSCRIPTION_ID/resourceGroups/rg-dev-pick/providers/Microsoft.Network/virtualNetworks/vnet-aks-pick/subnets/aks-pool-default"
