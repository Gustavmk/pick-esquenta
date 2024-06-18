k create deployment --image nginx nginx --port 80 -o yaml --dry-run=client > deployment.yaml

k expose deployment nginx 

k port-forward svc/nginx 8081:80


kubectl run -i --tty load-generator --image=busybox /bin/sh

while true; do wget -q -O- http://nginx.default.svc.cluster.local; done


# k6 

kubectl create configmap k6-test --from-file stresstest/k6.js


helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm install k6-operator grafana/k6-operator