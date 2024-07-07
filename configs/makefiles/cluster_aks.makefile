##------------------------------------------------------------------------
##                     AZURE K8S Cluster
##------------------------------------------------------------------------
deploy-aks-cluster:						# Cria o cluster na Azure
	bash configs/aks/aks-init.sh

delete-aks-cluster:						# Remove o cluster da Azure
	bash configs/aks/aks-remove.sh

set-context-aks:						# Atualiza contexto para AKS
	bash configs/aks/aks-set-context.sh
	#aws eks --region eu-central-1 update-kubeconfig --name ${CLUSTER_NAME}
	#kubectl config use-context arn:aws:eks:eu-central-1:$(shell aws sts get-caller-identity --output json | jq '.Account' -r):cluster/${CLUSTER_NAME} 
