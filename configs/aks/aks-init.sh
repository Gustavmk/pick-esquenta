#bin/bash
set -e 

clusterName="myOverlayCluster"
resourceGroup="myResourceGroup"
location="westcentralus"

# AKS
AKS_POD_CIDR='192.168.0.0/16'
AKS_K8S_VERSION='1.16.9'

az group create --name $resourceGroup --location $location

az aks create \
  --resource-group myResourceGroup \
  --name myAKSCluster \
  --enable-managed-identity \
  --node-count 1 \
  --generate-ssh-keys



az aks create --resource-group $resourceGroup --location $location \
    --name $clusterName  \
    --network-plugin azure \
    --network-plugin-mode overlay \
    --pod-cidr $AKS_POD_CIDR \
    --kubernetes-version $AKS_K8S_VERSION