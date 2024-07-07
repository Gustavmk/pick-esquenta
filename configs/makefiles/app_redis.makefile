REDIS_NAMESPACE := redis
REDIS_RELEASE := redis
REDIS_CHART_VALUES := configs/helm/redis/values.yml
REDIS_CHART_LOCAL_VALUES := configs/helm/redis/values-kind.yml
REDIS_CHART_EKS_VALUES := configs/helm/redis/values-eks.yml

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
