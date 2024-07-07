ARGOCD_RELEASE := argocd
ARGOCD_NAMESPACE := argocd
ARGOCD_CHART_VALUES := configs/helm/argocd/values.yml
ARGOCD_CHART_LOCAL_VALUES := configs/helm/argocd/values-kind.yml
ARGOCD_CHART_EKS_VALUES := configs/helm/argocd/values-eks.yml
ARGOCD_CHART_AKS_VALUES := configs/helm/argocd/values-aks.yml

##------------------------------------------------------------------------
##                    Comandos do Metrics Server
##------------------------------------------------------------------------
deploy-argocd-local:					# Realiza a instalação do Metrics Server no Kind
	helm repo add argo https://argoproj.github.io/argo-helm
	helm repo update
	helm upgrade -i ${ARGOCD_RELEASE} -n ${ARGOCD_NAMESPACE} argo/argo-cd \
		--set crds.install=true \
		--values ${ARGOCD_CHART_VALUES} \
		--values ${ARGOCD_CHART_LOCAL_VALUES} \
		--wait \
		--atomic \
		--debug \
		--timeout 3m \
		--create-namespace

	# argo/argo-workflows

	helm upgrade -i "${ARGOCD_RELEASE}-apps" -n ${ARGOCD_NAMESPACE} argo/argocd-apps \
		--set crds.install=true \
		--wait \
		--atomic \
		--debug \
		--timeout 3m \
		--create-namespace

deploy-argocd-eks:					# Realiza a instalação do Metrics Server no EKS
	helm repo add argo https://argoproj.github.io/argo-helm
	helm repo update
	helm upgrade -i ${ARGOCD_RELEASE} -n ${ARGOCD_NAMESPACE} argo/argo-cd \
		--values ${ARGOCD_CHART_VALUES} \
		--values ${ARGOCD_CHART_EKS_VALUES} \
		--wait \
		--atomic \
		--debug \
		--timeout 3m \
		--create-namespace

deploy-argocd-aks:					# Realiza a instalação do Metrics Server no AKS
	helm repo add argo https://argoproj.github.io/argo-helm
	helm repo update
	helm upgrade -i ${ARGOCD_RELEASE} -n ${ARGOCD_NAMESPACE} argo/argo-cd \
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
