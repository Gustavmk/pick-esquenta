
##------------------------------------------------------------------------
##                     AWS K8S Cluster
##------------------------------------------------------------------------
deploy-eks-cluster:						# Cria o cluster na AWS
	eksctl create cluster -f ${EKSCTL_CONFIG}

delete-eks-cluster:						# Remove o cluster na AWS
	eksctl delete cluster --name=${CLUSTER_NAME}

set-context-eks:					# Atualiza contexto para EKS
	aws eks --region eu-central-1 update-kubeconfig --name ${CLUSTER_NAME}
	kubectl config use-context arn:aws:eks:eu-central-1:$(shell aws sts get-caller-identity --output json | jq '.Account' -r):cluster/${CLUSTER_NAME} 
