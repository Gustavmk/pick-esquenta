
MAILHOG_RELEASE := email
MAILHOG_NAMESPACE := management
MAILHOG_CHART_VALUES := configs/helm/mailhog/values.yml
MAILHOG_LOCAL_VALUES := configs/helm/mailhog/values-kind.yml


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
