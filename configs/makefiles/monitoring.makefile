METRICS_SERVER_RELEASE := metrics-server
METRICS_SERVER_NAMESPACE := kube-system
METRICS_SERVER_CHART_VALUES := configs/helm/metrics-server/values.yml
METRICS_SERVER_CHART_LOCAL_VALUES := configs/helm/metrics-server/values-kind.yml
METRICS_SERVER_CHART_EKS_VALUES := configs/helm/metrics-server/values-eks.yml
METRICS_SERVER_CHART_AKS_VALUES := configs/helm/metrics-server/values-aks.yml

GRAFANA_LOKI_RELEASE := loki
GRAFANA_LOKI_NAMESPACE := monitoring
GRAFANA_LOKI_CHART_VALUES := configs/helm/grafana-loki/values.yml
GRAFANA_LOKI_LOCAL_VALUES := configs/helm/grafana-loki/values-local.yml
GRAFANA_LOKI_AKS_VALUES := configs/helm/grafana-loki/values-aks.yml

PROMTAIL_RELEASE := promtail
PROMTAIL_NAMESPACE := monitoring
PROMTAIL_CHART_VALUES := configs/helm/promtail/values.yml
PROMTAIL_CHART_LOCAL_VALUES := configs/helm/promtail/values-kind.yml

BLACKBOX_RELEASE := blackbox
BLACKBOX_NAMESPACE := monitoring
BLACKBOX_ROOT := configs/helm/blackbox-exporter
BLACKBOX_CHART_VALUES := ${BLACKBOX_ROOT}/values.yml
BLACKBOX_LOCAL_VALUES := ${BLACKBOX_ROOT}/values-local.yml

KUBE_PROMETHEUS_STACK_RELESE := kube-prometheus-stack
KUBE_PROMETHEUS_STACK_NAMESPACE := monitoring
KUBE_PROMETHEUS_STACK_CHART_VALUES := configs/helm/kube-prometheus-stack/values.yml
KUBE_PROMETHEUS_STACK_CHART_LOCAL_VALUES := configs/helm/kube-prometheus-stack/values-kind.yml
KUBE_PROMETHEUS_STACK_CHART_LOCAL_ALERTMANAGER_VALUES := configs/helm/kube-prometheus-stack/values-kind-alertmanager.yml
KUBE_PROMETHEUS_STACK_CHART_EKS_VALUES := configs/helm/kube-prometheus-stack/values-eks.yml
KUBE_PROMETHEUS_STACK_CHART_AKS_VALUES := configs/helm/kube-prometheus-stack/values-aks.yml


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

deploy-metrics-server-aks:					# Realiza a instalação do Metrics Server no AKS
	helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
	helm repo update
	# kubectl delete -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml --ignore-not-found 
	helm upgrade -i ${METRICS_SERVER_RELEASE} -n ${METRICS_SERVER_NAMESPACE} metrics-server/metrics-server \
		--values ${METRICS_SERVER_CHART_VALUES} \
		--values ${METRICS_SERVER_CHART_AKS_VALUES} \
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
		--timeout 5m \
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

deploy-kube-prometheus-stack-aks:		# Realiza a instalação do Prometheus no AKS
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo update
	helm upgrade -i ${KUBE_PROMETHEUS_STACK_RELESE} -n ${KUBE_PROMETHEUS_STACK_NAMESPACE} prometheus-community/kube-prometheus-stack \
		--values ${KUBE_PROMETHEUS_STACK_CHART_VALUES} \
		--values ${KUBE_PROMETHEUS_STACK_CHART_AKS_VALUES} \
		--wait \
		--atomic \
		--debug \
		--timeout 3m \
		--create-namespace

delete-kube-prometheus-stack:			# Remove a instalação do Prometheus
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


delete-grafana-loki:					# Comment here
	helm uninstall ${GRAFANA_LOKI_RELEASE} -n ${GRAFANA_LOKI_NAMESPACE}
	kubectl delete ns ${GRAFANA_LOKI_NAMESPACE}
