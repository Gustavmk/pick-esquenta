##------------------------------------------------------------------------
##                     Global vars
##------------------------------------------------------------------------

SRCDIR := configs/makefiles
KUBERNETES_LINT_CONFIG := configs/kubelinter/kubelinter-config.yaml
DOCKER_LINT_CONFIG := configs/hadolint/hadolint-config.yaml

# Clusters
include ${SRCDIR}/cluster_aks.makefile
include ${SRCDIR}/cluster_kind.makefile
include ${SRCDIR}/cluster_eks.makefile
include ${SRCDIR}/others.makefile

# Infra Solutions
include ${SRCDIR}/app_ingress.makefile
include ${SRCDIR}/app_redis.makefile
include ${SRCDIR}/app_mailhog.makefile
include ${SRCDIR}/monitoring.makefile
include ${SRCDIR}/argocd.makefile

# GENERAL APPS
include ${SRCDIR}/app_giropops_senhas.makefile


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

