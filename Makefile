##------------------------------------------------------------------------
##                     Global vars
##------------------------------------------------------------------------

# Directories
SRCDIR := configs/makefiles

# Clusters
include ${SRCDIR}/cluster_aks.makefile
include ${SRCDIR}/cluster_kind.makefile

# Infra Solutions
include ${SRCDIR}/app_mailhog.makefile

# APPS
include ${SRCDIR}/app_giropops_senhas.makefile

KUBERNETES_LINT_CONFIG := configs/kubelinter/kubelinter-config.yaml
DOCKER_LINT_CONFIG := configs/hadolint/hadolint-config.yaml

INGRESS_RELEASE := ingress-nginx
INGRESS_NAMESPACE := ingress-nginx
INGRESS_CHART_VALUES_EKS := configs/helm/ingress-nginx-controller/values-eks.yaml
INGRESS_CHART_VALUES_AKS := configs/helm/ingress-nginx-controller/values-aks.yaml

REDIS_NAMESPACE := redis
REDIS_RELEASE := redis
REDIS_CHART_VALUES := configs/helm/redis/values.yml
REDIS_CHART_LOCAL_VALUES := configs/helm/redis/values-kind.yml
REDIS_CHART_EKS_VALUES := configs/helm/redis/values-eks.yml

GO_SAMPLE_ROOT := apps/go-sample
GO_SAMPLE_BASE := ${GO_SAMPLE_ROOT}/manifests/base
GO_SAMPLE_LOCAL := ${GO_SAMPLE_ROOT}/manifests/overlays/kind
GO_SAMPLE_EKS := ${GO_SAMPLE_ROOT}/manifests/overlays/eks
GO_SAMPLE_DOCKERFILE := ${GO_SAMPLE_ROOT}/Dockerfile
GO_SAMPLE_NAMESPACE := go-sample


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

