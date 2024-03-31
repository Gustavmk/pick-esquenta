# deploy aks

```bash

# Install
helm repo add external-secrets https://charts.external-secrets.io

helm install external-secrets \
   external-secrets/external-secrets \
    -n external-secrets \
    --create-namespace \
    --set installCRDs=true


TENANT_ID=$(az account show --query tenantId | tr -d \")
RESOURCE_GROUP="rg-pick-esquenta"
LOCATION="eastus"
az group create --location $LOCATION --name $RESOURCE_GROUP
VAULT_NAME="vault-pick-esquenta"
az keyvault create --name $VAULT_NAME --resource-group $RESOURCE_GROUP


SECRET_NAME="example-externalsecret-key"
SECRET_VAlUE="This is our secret now"
az keyvault secret set --name $SECRET_NAME --vault-name $VAULT_NAME --value "$SECRET_VAlUE"


APP_NAME="ExtSectret Query App"
APP_ID=$(az ad app create --display-name "$APP_NAME" --query appId | tr -d \")
SERVICE_PRINCIPAL=$(az ad sp create --id $APP_ID --query objectId | tr -d \")
az ad app permission add --id $APP_ID --api-permissions f53da476-18e3-4152-8e01-aec403e6edc0=Scope --api cfa8b339-82a2-471a-a3c9-0fc0be7a4093
APP_PASSWORD="ThisisMyStrongPassword"
az ad app credential reset --id $APP_ID

az keyvault set-policy --name $VAULT_NAME --object-id $SERVICE_PRINCIPAL --secret-permissions get

kubectl create secret generic azure-secret-sp --from-literal=ClientID=$APP_ID --from-literal=ClientSecret=$APP_PASSWORD

## deploy external secrets

cat << EOF | kubectl apply -f -
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: azure-backend
spec:
  provider:
    azurekv:
      tenantId: $TENANT_ID
      vaultUrl: "https://$VAULT_NAME.vault.azure.net"
      authSecretRef:
        clientId:
          name: azure-secret-sp
          key: ClientID
        clientSecret:
          name: azure-secret-sp
          key: ClientSecret
---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: azure-example
spec:
  refreshInterval: 1h
  secretStoreRef:
    kind: SecretStore
    name: azure-backend
  target:
    name: azure-secret
  data:
  - secretKey: foobar
    remoteRef:
      key: example-externalsecret-key
EOF

# testing
kubectl get secret azure-secret -o jsonpath='{.data.foobar}' | base64 -d

# force refresh
kubectl annotate es azure-example force-sync=$(date +%s) --overwrite

```
