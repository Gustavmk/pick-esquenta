echo "drylabs" | base64
result: ZHJ5bGFicwo=
echo 'password-!-drylabs' | base64
result: cGFzc3dvcmQtIS1kcnlsYWJzCg==

# chose one from env-file, file, literal
k create secret generic drylabs-secret --from-


k create secret generic drylabs-secret --from-literal=username=ZHJ5bGFicwo= --from-literal=password=cGFzc3dvcmQtIS1kcnlsYWJzCg== --dry-run=client --output=yaml