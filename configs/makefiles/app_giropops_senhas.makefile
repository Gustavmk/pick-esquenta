GIROPOPS_SENHAS_ROOT := apps/giropops-senhas
GIROPOPS_SENHAS_BASE := ${GIROPOPS_SENHAS_ROOT}/manifests/base
GIROPOPS_SENHAS_LOCAL := ${GIROPOPS_SENHAS_ROOT}/manifests/overlays/kind
GIROPOPS_SENHAS_EKS := ${GIROPOPS_SENHAS_ROOT}/manifests/overlays/eks
GIROPOPS_SENHAS_DOCKERFILE := ${GIROPOPS_SENHAS_ROOT}/Dockerfile
GIROPOPS_SENHAS_NAMESPACE := giropops-senhas


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
