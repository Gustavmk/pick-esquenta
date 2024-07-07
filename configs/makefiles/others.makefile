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
	@grep -E '^[a-zA-Z0-9 -]+:.*#' $(MAKEFILE_LIST) | sort | while read -r l; do printf "\033[1;32m$$(echo $$l | cut -f 2 -d':')\033[00m:$$(echo $$l | cut -f 2- -d'#')\n"; done

