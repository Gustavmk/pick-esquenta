#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Execute o script como usuário root (ou sudo)"
  exit
fi


# Define an array of hostnames
hosts=(
    "giropops-senhas.kubernetes.docker.internal"
    "alertmanager.kubernetes.docker.internal"
    "prometheus.kubernetes.docker.internal"
    "grafana.kubernetes.docker.internal"
    "goldilocks.kubernetes.docker.internal"
    "mailhog.kubernetes.docker.internal"
    "argocd.kubernetes.docker.internal"
)

# Loop through the hostnames
for host in "${hosts[@]}"; do
    # Check if the hostname is already in /etc/hosts, if not, add it
    if ! grep -i "127.0.0.1 $host" /etc/hosts > /dev/null; then
        echo "127.0.0.1 $host" >> /etc/hosts
    fi
done

echo "Hosts adicionados!"