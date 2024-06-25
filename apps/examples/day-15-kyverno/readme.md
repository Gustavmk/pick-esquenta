helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update 

helm install kyverno kyverno/kyverno --namespace kyverno --create-namespace

k get pod -n kyverno
kubectl get crd | grep kyverno