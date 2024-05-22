# Querys

```bash
# Query all pods with selector release=value
kubectl --namespace monitoring get pods -l "release=kube-prometheus-stack"

# Query all resources in all namespaces with selector app=value
kubectl get all --all-namespaces -l "app=kube-prometheus-stack-coredns"
``` 
