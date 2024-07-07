ARGOCD_RELEASE := argocd
ARGOCD_NAMESPACE := kube-system
ARGOCD_CHART_VALUES := configs/helm/argocd/values.yml
ARGOCD_CHART_LOCAL_VALUES := configs/helm/argocd/values-kind.yml
ARGOCD_CHART_EKS_VALUES := configs/helm/argocd/values-eks.yml
ARGOCD_CHART_AKS_VALUES := configs/helm/argocd/values-aks.yml


##------------------------------------------------------------------------
##                    Comandos do Metrics Server
##------------------------------------------------------------------------
deploy-argocd-local:					# Realiza a instalação do Metrics Server no Kind
	helm repo add argocd https://kubernetes-sigs.github.io/argocd/
	helm repo update
	helm upgrade -i ${ARGOCD_RELEASE} -n ${ARGOCD_NAMESPACE} argocd/argocd \
		--values ${ARGOCD_CHART_VALUES} \
		--values ${ARGOCD_CHART_LOCAL_VALUES} \
		--wait \
		--atomic \
		--debug \
		--timeout 3m \
		--create-namespace

deploy-argocd-eks:					# Realiza a instalação do Metrics Server no EKS
	helm repo add argocd https://kubernetes-sigs.github.io/argocd/
	helm repo update
	helm upgrade -i ${ARGOCD_RELEASE} -n ${ARGOCD_NAMESPACE} argocd/argocd \
		--values ${ARGOCD_CHART_VALUES} \
		--values ${ARGOCD_CHART_EKS_VALUES} \
		--wait \
		--atomic \
		--debug \
		--timeout 3m \
		--create-namespace

deploy-argocd-aks:					# Realiza a instalação do Metrics Server no AKS
	helm repo add argocd https://kubernetes-sigs.github.io/argocd/
	helm repo update
	# kubectl delete -f https://github.com/kubernetes-sigs/argocd/releases/latest/download/components.yaml --ignore-not-found 
	helm upgrade -i ${ARGOCD_RELEASE} -n ${ARGOCD_NAMESPACE} argocd/argocd \
		--values ${ARGOCD_CHART_VALUES} \
		--values ${ARGOCD_CHART_AKS_VALUES} \
		--wait \
		--atomic \
		--debug \
		--timeout 3m \
		--create-namespace

delete-argocd:					# Remove a instalação do Metrics Server no EKS
	helm uninstall ${ARGOCD_RELEASE} -n ${ARGOCD_NAMESPACE}
	kubectl delete ns ${ARGOCD_NAMESPACE}
