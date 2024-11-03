# https://github.com/eksctl-io/eksctl/tree/main/examples
##------------------------------------------------------------------------
##                     AWS K8S Cluster
##------------------------------------------------------------------------

EKSCTL_CONFIG := configs/eksctl/config.yaml

deploy-eks-cluster:						# Cria o cluster na AWS
	eksctl create cluster -f ${EKSCTL_CONFIG}

	# Instalação do AWS CNI
	# Validade cluster version 
	# https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html
	eksctl create addon --name vpc-cni --version v1.18.2-eksbuild.1 --cluster pick --force
	# in AWS eddit addon - {"enableNetworkPolicy": "true"}
	eksctl get addon --cluster pick

delete-eks-cluster:						# Remove o cluster na AWS
	#eksctl get cluster
	eksctl delete cluster --name=pick
	
	# Validate 
	aws-nuke -c configs/eksctl/cloud-nuke.yml --profile default 
	# Then
	# aws-nuke -c configs/eksctl/cloud-nuke.yml --profile default --no-dry-run        
	

set-context-eks:					# Atualiza contexto para EKS
	aws eks --region us-east-2 update-kubeconfig --name ${CLUSTER_NAME}
	kubectl config use-context arn:aws:eks:eu-central-1:$(shell aws sts get-caller-identity --output json | jq '.Account' -r):cluster/${CLUSTER_NAME} 
