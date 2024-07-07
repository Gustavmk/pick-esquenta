INGRESS_RELEASE := ingress-nginx
INGRESS_NAMESPACE := ingress-nginx
INGRESS_CHART_VALUES_EKS := configs/helm/ingress-nginx-controller/values-eks.yaml
INGRESS_CHART_VALUES_AKS := configs/helm/ingress-nginx-controller/values-aks.yaml

##------------------------------------------------------------------------
##                     Comandos do Ingress - AKS
##------------------------------------------------------------------------
deploy-ingress-aks:						# Realiza o deploy do ingress no AKS
	helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
	helm repo update
	helm upgrade -i ${INGRESS_RELEASE} -n ${INGRESS_NAMESPACE} ingress-nginx/ingress-nginx \
		--values ${INGRESS_CHART_VALUES_AKS} \
		--wait \
		--atomic \
		--debug \
		--timeout 3m \
		--create-namespace

	helm upgrade -i ${INGRESS_RELEASE} -n ${INGRESS_NAMESPACE} ingress-nginx/ingress-nginx \
		--values ${INGRESS_CHART_VALUES_AKS} \
		--wait \
		--atomic \
		--debug \
		--timeout 3m \
		--create-namespace

delete-ingress-AKS:						# Realiza a deleção do ingress no AKS
	helm uninstall ${INGRESS_RELEASE} -n ${INGRESS_NAMESPACE}
	kubectl delete ns ${INGRESS_NAMESPACE}

##------------------------------------------------------------------------
##                     Comandos do Ingress - EKS
##------------------------------------------------------------------------
deploy-ingress-eks:						# Realiza o deploy do ingress no EKS
	helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
	helm repo update
	helm upgrade -i ${INGRESS_RELEASE} -n ${INGRESS_NAMESPACE} ingress-nginx/ingress-nginx \
		--values ${INGRESS_CHART_VALUES_EKS} \
		--wait \
		--atomic \
		--debug \
		--timeout 3m \
		--create-namespace

delete-ingress-eks:						# Realiza a deleção do ingress no EKS
	helm uninstall ${INGRESS_RELEASE} -n ${INGRESS_NAMESPACE}
	kubectl delete ns ${INGRESS_NAMESPACE}
