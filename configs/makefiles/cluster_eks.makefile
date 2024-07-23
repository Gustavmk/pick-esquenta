# https://github.com/eksctl-io/eksctl/tree/main/examples
##------------------------------------------------------------------------
##                     AWS K8S Cluster
##------------------------------------------------------------------------
deploy-eks-cluster:						# Cria o cluster na AWS
	eksctl create cluster -f ${EKSCTL_CONFIG}

delete-eks-cluster:						# Remove o cluster na AWS
	#eksctl get cluster
	eksctl delete cluster --name=${CLUSTER_NAME}
	
	# Validate 
	aws-nuke -c configs/eksctl/cloud-nuke.yml --profile default 
	# Then
	# aws-nuke -c configs/eksctl/cloud-nuke.yml --profile default --no-dry-run        
	

set-context-eks:					# Atualiza contexto para EKS
	aws eks --region us-east-2 update-kubeconfig --name ${CLUSTER_NAME}
	kubectl config use-context arn:aws:eks:eu-central-1:$(shell aws sts get-caller-identity --output json | jq '.Account' -r):cluster/${CLUSTER_NAME} 
