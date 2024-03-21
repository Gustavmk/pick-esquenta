##------------------------------------------------------------------------
##                     Global vars
##------------------------------------------------------------------------
CLUSTER_NAME := kind
CLUSTER_CONFIG := configs/kind/cluster.yaml
EKSCTL_CONFIG := configs/eksctl/config.yaml

KUBERNETES_LINT_CONFIG := configs/kubelinter/kubelinter-config.yaml
DOCKER_LINT_CONFIG := configs/hadolint/hadolint-config.yaml

METRICS_SERVER_RELEASE := metrics-server
METRICS_SERVER_NAMESPACE := kube-system
METRICS_SERVER_CHART_VALUES := configs/helm/metrics-server/values.yml
METRICS_SERVER_CHART_LOCAL_VALUES := configs/helm/metrics-server/values-kind.yml
METRICS_SERVER_CHART_EKS_VALUES := configs/helm/metrics-server/values-eks.yml

MAILHOG_RELEASE := email
MAILHOG_NAMESPACE := management
MAILHOG_CHART_VALUES := configs/helm/mailhog/values.yml
MAILHOG_LOCAL_VALUES := configs/helm/mailhog/values-kind.yml

GRAFANA_LOKI_RELEASE := loki
GRAFANA_LOKI_NAMESPACE := monitoring
GRAFANA_LOKI_CHART_VALUES := configs/helm/grafana-loki/values.yml
GRAFANA_LOKI_LOCAL_VALUES := configs/helm/grafana-loki/values-local.yml
GRAFANA_LOKI_AKS_VALUES := configs/helm/grafana-loki/values-aks.yml

PROMTAIL_RELEASE := promtail
PROMTAIL_NAMESPACE := monitoring
PROMTAIL_CHART_VALUES := configs/helm/promtail/values.yml
PROMTAIL_CHART_LOCAL_VALUES := configs/helm/promtail/values-kind.yml

GOLDILOCKS_RELEASE := goldilocks
GOLDILOCKS_NAMESPACE := management
GOLDILOCKS_CHART_VALUES := configs/helm/goldilocks/values.yml
GOLDILOCKS_LOCAL_VALUES := configs/helm/goldilocks/values-local.yml
GOLDILOCKS_AKS_VALUESS := configs/helm/goldilocks/values-aks.yml

BLACKBOX_RELEASE := blackbox
BLACKBOX_NAMESPACE := monitoring
BLACKBOX_ROOT := configs/helm/blackbox-exporter
BLACKBOX_CHART_VALUES := ${BLACKBOX_ROOT}/values.yml
BLACKBOX_LOCAL_VALUES := ${BLACKBOX_ROOT}/values-local.yml

INGRESS_RELEASE := ingress-nginx
INGRESS_NAMESPACE := ingress-nginx
INGRESS_CHART_VALUES_EKS := configs/helm/ingress-nginx-controller/values.yaml

REDIS_NAMESPACE := redis
REDIS_RELEASE := redis
REDIS_CHART_VALUES := configs/helm/redis/values.yml
REDIS_CHART_LOCAL_VALUES := configs/helm/redis/values-kind.yml
REDIS_CHART_EKS_VALUES := configs/helm/redis/values-eks.yml

KUBE_PROMETHEUS_STACK_RELESE := kube-prometheus-stack
KUBE_PROMETHEUS_STACK_NAMESPACE := monitoring
KUBE_PROMETHEUS_STACK_CHART_VALUES := configs/helm/kube-prometheus-stack/values.yml
KUBE_PROMETHEUS_STACK_CHART_LOCAL_VALUES := configs/helm/kube-prometheus-stack/values-kind.yml
KUBE_PROMETHEUS_STACK_CHART_LOCAL_ALERTMANAGER_VALUES := configs/helm/kube-prometheus-stack/values-kind-alertmanager.yml
KUBE_PROMETHEUS_STACK_CHART_EKS_VALUES := configs/helm/kube-prometheus-stack/values-eks.yml

GIROPOPS_SENHAS_ROOT := apps/giropops-senhas
GIROPOPS_SENHAS_BASE := ${GIROPOPS_SENHAS_ROOT}/manifests/base
GIROPOPS_SENHAS_LOCAL := ${GIROPOPS_SENHAS_ROOT}/manifests/overlays/kind
GIROPOPS_SENHAS_EKS := ${GIROPOPS_SENHAS_ROOT}/manifests/overlays/eks
GIROPOPS_SENHAS_DOCKERFILE := ${GIROPOPS_SENHAS_ROOT}/Dockerfile
GIROPOPS_SENHAS_NAMESPACE := giropops-senhas

GO_SAMPLE_ROOT := apps/go-sample
GO_SAMPLE_BASE := ${GO_SAMPLE_ROOT}/manifests/base
GO_SAMPLE_LOCAL := ${GO_SAMPLE_ROOT}/manifests/overlays/kind
GO_SAMPLE_EKS := ${GO_SAMPLE_ROOT}/manifests/overlays/eks
GO_SAMPLE_DOCKERFILE := ${GO_SAMPLE_ROOT}/Dockerfile
GO_SAMPLE_NAMESPACE := go-sample

##------------------------------------------------------------------------
##                     Local K8S Cluster
##------------------------------------------------------------------------
deploy-kind-cluster:					# Realiza a instalação do cluster local
	kind get clusters | grep -i ${CLUSTER_NAME} && echo "Cluster já existe" || kind create cluster --wait 120s --name ${CLUSTER_NAME} --config ${CLUSTER_CONFIG}
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
	kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=270s
	$(MAKE) deploy-app-tests

deploy-app-tests: 						# Provisiona recursos para testes locais
	kubectl apply -f configs/kind/namespace.yml
	kubectl apply -f apps/nginx/
	kubectl apply -f apps/bad-app/namespace.yml
	kubectl apply -f apps/bad-app/deployment.yml

delete-kind-cluster:					# Remove o cluster local
	kind get clusters | grep -i ${CLUSTER_NAME} && kind delete clusters ${CLUSTER_NAME} || echo "Cluster não existe"

set-context-kind:						# Atualiza contexto do Kind
	kind get clusters | grep -i ${CLUSTER_NAME} || (echo "Cluster não existe" && exit 1)
	kubectl config use-context kind-${CLUSTER_NAME}
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

##------------------------------------------------------------------------
##                     AZURE K8S Cluster
##------------------------------------------------------------------------
# TODO: criar etapa de criação de cluster AKS

# deploy-aks-cluster:						# Cria o cluster na AWS
# 	#eksctl create cluster -f ${EKSCTL_CONFIG}

# delete-aks-cluster:						# Remove o cluster na AWS
# 	#eksctl delete cluster --name=${CLUSTER_NAME}

# set-context-aks:					# Atualiza contexto para EKS
# 	az account set -s ${AZURE_AKS_SUBSCRIPTION} 
# 	az aks get-credentials --resource-group ${AZURE_} --name aks-mvx-development-eastus-1 --overwrite-existing
# 	#kubectl config use-context arn:aws:eks:eu-central-1:$(shell aws sts get-caller-identity --output json | jq '.Account' -r):cluster/${CLUSTER_NAME} 

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

##------------------------------------------------------------------------
##                    Comandos do Metrics Server
##------------------------------------------------------------------------
deploy-metrics-server-local:					# Realiza a instalação do Metrics Server no Kind
	helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
	helm repo update
	helm upgrade -i ${METRICS_SERVER_RELEASE} -n ${METRICS_SERVER_NAMESPACE} metrics-server/metrics-server \
		--values ${METRICS_SERVER_CHART_VALUES} \
		--values ${METRICS_SERVER_CHART_LOCAL_VALUES} \
		--wait \
		--atomic \
		--debug \
		--timeout 3m \
		--create-namespace

deploy-metrics-server-eks:					# Realiza a instalação do Metrics Server no EKS
	helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
	helm repo update
	helm upgrade -i ${METRICS_SERVER_RELEASE} -n ${METRICS_SERVER_NAMESPACE} metrics-server/metrics-server \
		--values ${METRICS_SERVER_CHART_VALUES} \
		--values ${METRICS_SERVER_CHART_EKS_VALUES} \
		--wait \
		--atomic \
		--debug \
		--timeout 3m \
		--create-namespace

delete-metrics-server:					# Remove a instalação do Metrics Server no EKS
	helm uninstall ${METRICS_SERVER_RELEASE} -n ${METRICS_SERVER_NAMESPACE}
	kubectl delete ns ${METRICS_SERVER_NAMESPACE}

##------------------------------------------------------------------------
##                    Comandos do Blackbox
##------------------------------------------------------------------------

deploy-blackbox-local:
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm upgrade -i ${BLACKBOX_RELEASE} -n ${BLACKBOX_NAMESPACE} \
		prometheus-community/prometheus-blackbox-exporter \
		--values ${BLACKBOX_CHART_VALUES} \
		--values ${BLACKBOX_LOCAL_VALUES} \
		--wait \
		--atomic \
		--debug \
		--timeout 3m \
		--create-namespace
	kubectl apply -f ${BLACKBOX_ROOT}/service-monitor.yml -n ${BLACKBOX_NAMESPACE}

##------------------------------------------------------------------------
##                    Comandos do Mailhog - Testando E-mail em desenvolvimento
##------------------------------------------------------------------------
deploy-email-local:		 					# Realiza a instalação do Mailhog server no Kind
		helm repo add codecentric https://codecentric.github.io/helm-charts
		helm repo update
		helm upgrade -i ${MAILHOG_RELEASE} -n ${MAILHOG_NAMESPACE} codecentric/mailhog \
		--values ${MAILHOG_CHART_VALUES} \
		--values ${MAILHOG_LOCAL_VALUES} \
		--wait \
		--atomic \
		--debug \
		--timeout 3m \
		--create-namespace


delete-email:					# Remove a instalação do Mailhog server
	helm uninstall ${MAILHOG_RELEASE} -n ${MAILHOG_NAMESPACE}
	kubectl delete ns ${MAILHOG_NAMESPACE}

##------------------------------------------------------------------------
##                    Comandos do Goldilocks
##------------------------------------------------------------------------
# https://github.com/FairwindsOps/charts/tree/master/stable/goldilocks
deploy-goldilocks-local:					# Realiza a instalação do Metrics Server no Kind
		helm repo add fairwinds-stable https://charts.fairwinds.com/stable
		helm upgrade -i ${GOLDILOCKS_RELEASE} -n ${GOLDILOCKS_NAMESPACE} fairwinds-stable/goldilocks \
		--values ${GOLDILOCKS_CHART_VALUES} \
		--values ${GOLDILOCKS_LOCAL_VALUES} \
		--wait \
		--atomic \
		--debug \
		--timeout 3m \
		--create-namespace


deploy-goldilocks-aks:					# Realiza a instalação do Metrics Server no Kind
		helm repo add fairwinds-stable https://charts.fairwinds.com/stable
		helm upgrade -i ${GOLDILOCKS_RELEASE} -n ${GOLDILOCKS_NAMESPACE} fairwinds-stable/goldilocks \
		--values ${GOLDILOCKS_CHART_VALUES} \
		--values ${GOLDILOCKS_AKS_VALUES} \
		--wait \
		--atomic \
		--debug \
		--timeout 3m \
		--create-namespace

delete-goldilocks:					# Remove a instalação do Metrics Server no EKS
	helm uninstall ${GOLDILOCKS_RELEASE} -n ${GOLDILOCKS_NAMESPACE}
	kubectl delete ns ${GOLDILOCKS_NAMESPACE}
##------------------------------------------------------------------------
##                    Comandos do Redis
##------------------------------------------------------------------------
# https://github.com/bitnami/charts/tree/main/bitnami/redis
deploy-redis-local:						# Realiza a instalação do Redis localmente
	helm upgrade -i ${REDIS_RELEASE} -n ${REDIS_NAMESPACE} oci://registry-1.docker.io/bitnamicharts/redis \
		--values ${REDIS_CHART_VALUES} \
		--values ${REDIS_CHART_LOCAL_VALUES} \
		--wait \
		--atomic \
		--debug \
		--timeout 6m \
		--create-namespace

deploy-redis-eks:						# Realiza a instalação do Redis no EKS
	helm upgrade -i ${REDIS_RELEASE} -n ${REDIS_NAMESPACE} oci://registry-1.docker.io/bitnamicharts/redis \
		--values ${REDIS_CHART_VALUES} \
		--values ${REDIS_CHART_EKS_VALUES} \
		--wait \
		--atomic \
		--debug \
		--timeout 3m \
		--create-namespace

delete-redis:							# Remove a instalação do Redis
	helm uninstall ${REDIS_RELEASE} -n ${REDIS_NAMESPACE}
	kubectl delete ns ${REDIS_NAMESPACE}

##------------------------------------------------------------------------
##                     Comandos do Prometheus
##------------------------------------------------------------------------
deploy-kube-prometheus-stack-local:		# Realiza a instalação do Prometheus localmente
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo update
	helm upgrade -i ${KUBE_PROMETHEUS_STACK_RELESE} -n ${KUBE_PROMETHEUS_STACK_NAMESPACE} prometheus-community/kube-prometheus-stack \
		--values ${KUBE_PROMETHEUS_STACK_CHART_VALUES} \
		--values ${KUBE_PROMETHEUS_STACK_CHART_LOCAL_VALUES} \
		--values ${KUBE_PROMETHEUS_STACK_CHART_LOCAL_ALERTMANAGER_VALUES} \
		--wait \
		--atomic \
		--debug \
		--timeout 3m \
		--create-namespace

deploy-kube-prometheus-stack-alertmanager-config-local:		# Realiza a configuração do AlertManager localmente para testes de alertas
	kubectl delete secret --ignore-not-found -n ${KUBE_PROMETHEUS_STACK_NAMESPACE} alertmanager-secret-files
	kubectl create secret generic -n ${KUBE_PROMETHEUS_STACK_NAMESPACE} alertmanager-secret-files \
  		--from-literal="opsgenie-api-key=${ALERTMANAGER_OPSGENIE_API_KEY}" \
  		--from-literal="slack-api-url=${ALERTMANAGER_SLACK_API_URL}" \
	    --from-literal="telegram-api-token=${ALERTMANAGER_TELEGRAM_TOKEN}" 
	kubectl delete pod --ignore-not-found -n kube-prometheus-stack alertmanager-kube-prometheus-stack-alertmanager-0

deploy-kube-prometheus-stack-eks:		# Realiza a instalação do Prometheus no EKS
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo update
	helm upgrade -i ${KUBE_PROMETHEUS_STACK_RELESE} -n ${KUBE_PROMETHEUS_STACK_NAMESPACE} prometheus-community/kube-prometheus-stack \
		--values ${KUBE_PROMETHEUS_STACK_CHART_VALUES} \
		--values ${KUBE_PROMETHEUS_STACK_CHART_EKS_VALUES} \
		--wait \
		--atomic \
		--debug \
		--timeout 3m \
		--create-namespace

deploy-kube-prometheus-stack:			# Remove a instalação do Prometheus
	helm uninstall ${KUBE_PROMETHEUS_STACK_RELESE} -n ${KUBE_PROMETHEUS_STACK_NAMESPACE}
	kubectl delete namespace ${KUBE_PROMETHEUS_STACK_NAMESPACE}
	kubectl delete crd alertmanagerconfigs.monitoring.coreos.com
	kubectl delete crd alertmanagers.monitoring.coreos.com
	kubectl delete crd podmonitors.monitoring.coreos.com
	kubectl delete crd probes.monitoring.coreos.com
	kubectl delete crd prometheusagents.monitoring.coreos.com
	kubectl delete crd prometheuses.monitoring.coreos.com
	kubectl delete crd prometheusrules.monitoring.coreos.com
	kubectl delete crd scrapeconfigs.monitoring.coreos.com
	kubectl delete crd servicemonitors.monitoring.coreos.com
	kubectl delete crd thanosrulers.monitoring.coreos.com

##------------------------------------------------------------------------
##                    Comandos do Grafana Loki
##------------------------------------------------------------------------
deploy-grafana-loki-local:					# Comment here
	helm repo add grafana https://grafana.github.io/helm-charts
	helm upgrade -i ${GRAFANA_LOKI_RELEASE} -n ${GRAFANA_LOKI_NAMESPACE} grafana/loki-distributed \
	  --values ${GRAFANA_LOKI_CHART_VALUES} \
	  --values ${GRAFANA_LOKI_LOCAL_VALUES} \
	  --wait \
	  --atomic \
	  --debug \
	  --timeout 3m \
	  --create-namespace
	helm upgrade -i ${PROMTAIL_RELEASE} -n ${PROMTAIL_NAMESPACE} grafana/promtail \
	  --values ${PROMTAIL_CHART_VALUES} \
	  --values ${PROMTAIL_CHART_LOCAL_VALUES} \
	  --wait \
	  --atomic \
	  --debug \
	  --timeout 3m \
	  --create-namespace

# TODO: provisionar AKS pendente
# deploy-grafana-loki-aks:					# Comment here
# 		helm repo add grafana https://grafana.github.io/helm-charts
# 		helm upgrade -i ${GRAFANA_LOKI_RELEASE} -n ${GRAFANA_LOKI_NAMESPACE} grafana/loki \
# 		--version ${GRAFANA_LOKI_VERSION} \
# 		--values ${GRAFANA_LOKI_CHART_VALUES} \
# 		--values ${GRAFANA_LOKI_AKS_VALUES} \
# 		--wait \
# 		--atomic \
# 		--debug \
# 		--timeout 3m \
# 		--create-namespace

delete-grafana-loki:					# Comment here
	helm uninstall ${GRAFANA_LOKI_RELEASE} -n ${GRAFANA_LOKI_NAMESPACE}
	kubectl delete ns ${GRAFANA_LOKI_NAMESPACE}
##------------------------------------------------------------------------
##                     Comandos do Giropops
##------------------------------------------------------------------------
build-image-giropops-senhas:					# Realiza o build da imagem Giropops Senhas
	docker build -t giropops-senhas-python-chainguard:${GIROPOPS_SENHAS_TAG} -f ${GIROPOPS_SENHAS_DOCKERFILE} ${GIROPOPS_SENHAS_ROOT}

build-image-go-sample:							# Realiza o build da imagem Go Sample
	#docker build -t go-sample:${APPS_TAG} -f ${GO_SAMPLE_DOCKERFILE} ${GO_SAMPLE_ROOT}"
	
build-image-all:
	$(MAKE) build-image-giropops-senhas
	$(MAKE) build-image-go-sample

scan-image:								# Realiza o scan da imagem usando Trivy
	#trivy image giropops-senhas-python-chainguard:${GIROPOPS_SENHAS_TAG} --severity HIGH,CRITICAL --exit-code 1
	trivy image giropops-senhas-python-chainguard:${GIROPOPS_SENHAS_TAG} --severity HIGH,CRITICAL --exit-code 0

load-image:
	kind load docker-image giropops-senhas-python-chainguard:${GIROPOPS_SENHAS_TAG} -n ${CLUSTER_NAME}

build-scan-push-local:					# Realiza o build, análise e push da imagem para o cluster local para fim de testes
	$(MAKE) build-image-all
	$(MAKE) scan-image
	$(MAKE) load-image

push-image-dockerhub-ci:    			# Realiza o push da imagem para o Dockerhub - Somente CI
	docker login -u ${DOCKERHUB_USERNAME} -p ${DOCKERHUB_TOKEN}
	docker tag docker.io/library/giropops-senhas-python-chainguard:${GIROPOPS_SENHAS_TAG} ${DOCKERHUB_USERNAME}/giropops-senhas-python-chainguard:${GIROPOPS_SENHAS_TAG}
	docker push ${DOCKERHUB_USERNAME}/giropops-senhas-python-chainguard:${GIROPOPS_SENHAS_TAG}
	cosign sign --yes --rekor-url "https://rekor.sigstore.dev/" ${DOCKERHUB_USERNAME}/giropops-senhas-python-chainguard:${GIROPOPS_SENHAS_TAG}

deploy-giropops-senhas-kind:			
	kubectl create ns ${GIROPOPS_SENHAS_NAMESPACE} || echo "Namespace já existe"
	kubectl apply -k ${GIROPOPS_SENHAS_LOCAL}
	kubectl rollout restart deployment -n ${GIROPOPS_SENHAS_NAMESPACE} giropops-senhas

deploy-giropops-senhas-eks:			   
	kubectl create ns ${GIROPOPS_SENHAS_NAMESPACE} || echo "Namespace já existe"
	cd ${GIROPOPS_SENHAS_BASE} && kustomize edit set image giropops-senhas-python-chainguard=${DOCKERHUB_USERNAME}/giropops-senhas-python-chainguard:${GIROPOPS_SENHAS_TAG}
	kubectl apply -k ${GIROPOPS_SENHAS_EKS}

deploy-giropops-senhas-local:  			# Realiza deploy no Kind
	$(MAKE) set-context-kind
	$(MAKE) deploy-giropops-senhas-kind

deploy-giropops-senhas-aws:  			# Realiza deploy no EKS
	$(MAKE) set-context-eks
	$(MAKE) deploy-giropops-senhas-eks

delete-giropops-senhas:					# Remove a instalação do Giropops Senhas
	kubectl delete -f ${GIROPOPS_SENHAS_MANIFESTS}

##------------------------------------------------------------------------
##                     Comandos P/ Lint
##------------------------------------------------------------------------
lint-manifests:							# Lint kubernetes manifests
	docker run -v ./${GIROPOPS_SENHAS_MANIFESTS}:/dir -v ./${KUBERNETES_LINT_CONFIG}:/etc/config.yaml stackrox/kube-linter lint /dir --config /etc/config.yaml

lint-dockerfile:						# Lint Dockerfile
	docker run --rm -i -v ./${DOCKER_LINT_CONFIG}:/.config/hadolint.yaml hadolint/hadolint < ${GIROPOPS_SENHAS_DOCKERFILE}

##------------------------------------------------------------------------
##                     Comandos P/ Subir Ambiente Completo
##------------------------------------------------------------------------
deploy-all-local:						# Sobe a infra completa localmente num cluster Kind
	$(MAKE) deploy-kind-cluster
	$(MAKE) deploy-kube-prometheus-stack-local
	$(MAKE) deploy-redis-local
	$(MAKE) deploy-metrics-server-local
	$(MAKE) build-scan-push-local
	$(MAKE) deploy-giropops-senhas-local

deploy-infra-local:						# Sobe a infra sem Apps localmente num cluster Kind
	$(MAKE) deploy-kind-cluster
	$(MAKE) deploy-kube-prometheus-stack-local
	$(MAKE) deploy-kube-prometheus-stack-alertmanager-config-local
	$(MAKE) deploy-grafana-loki-local
	$(MAKE) deploy-metrics-server-local
	$(MAKE) deploy-email-local
	$(MAKE) deploy-goldilocks-local
	$(MAKE) deploy-blackbox-local

deploy-infra-aws:						# Sobe a infra completa na AWS
	$(MAKE) deploy-eks-cluster
	$(MAKE) deploy-ingress-eks
	$(MAKE) deploy-kube-prometheus-stack-eks
	$(MAKE) deploy-redis-eks
	$(MAKE) deploy-metrics-server-eks

##------------------------------------------------------------------------
##                     Comandos de cleanup
##------------------------------------------------------------------------
clean-local:							# Clean do ambiente local
	$(MAKE) set-context-kind
	$(MAKE) delete-kind-cluster

clean-aws:								# Clean do ambiente na AWS
	$(MAKE) set-context-eks
	$(MAKE) drop-pdb
	$(MAKE) delete-eks-cluster

##------------------------------------------------------------------------
##                     Stress Test
##------------------------------------------------------------------------
.PHONY: loadtest
start-loadtest:		        			# Executa loadtest usando K6 enviando os resultados para o Prometheus
	k6 run -o experimental-prometheus-rw --tag testid=exec-$(shell date +"%d-%m-%y:%T") loadtest/generate-keys.js

##------------------------------------------------------------------------
##                     Utils
##------------------------------------------------------------------------
.PHONY: drop-pdb						
drop-pdb:								# Dropa os PDBs do cluster
	bash scripts/drop-pdb.sh


load-hosts:								# Adiciona hosts localmente (unix-like only!)
	sudo bash scripts/hosts.sh

##------------------------------------------------------------------------
##                     Helper
##------------------------------------------------------------------------
help:									# Mostra help
	@grep -E '^[a-zA-Z0-9 -]+:.*#'  Makefile | sort | while read -r l; do printf "\033[1;32m$$(echo $$l | cut -f 1 -d':')\033[00m:$$(echo $$l | cut -f 2- -d'#')\n"; done
