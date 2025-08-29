##------------------------------------------------------------------------
##                     Local K8S Cluster
##------------------------------------------------------------------------
CLUSTER_NAME := localk8s
CLUSTER_CONFIG := configs/kind/cluster.yaml

deploy-kind-cluster:					# Realiza a instalação do cluster local
	kind get clusters | grep -i ${CLUSTER_NAME} && echo "Cluster já existe" || kind create cluster --wait 120s --name ${CLUSTER_NAME} --config ${CLUSTER_CONFIG}
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
	kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=270s

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
