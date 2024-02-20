# Notes for AlertManager configuration 

- link to talk with The BotFather. https://telegram.me/BotFather. For a description of the Bot API, see this page: https://core.telegram.org/bots/api
- AlertManager https://prometheus.io/docs/alerting/latest/configuration/
- Kube-prometheus-stack https://prometheus-operator.dev/docs/user-guides/alerting/
- Helm chart https://github.com/prometheus-operator/kube-prometheus

Videos to take a look
- https://www.youtube.com/watch?v=pPpm06Gz1IE
- https://www.youtube.com/watch?v=HiIV-TyS-O8


## Telegram

```json
GET https://api.telegram.org/botYOUR_BOT_TOKEN/getUpdates

RESULT: 
"channel_post":{"message_id":5,"sender_chat":{"id":-1002019095946,"title":"PromTest2123","type":"channel"},"chat":{"id":-1002019095946,"title":"PromTest2123","type":"channel"},"date":1708206931,"text":"'oi"}}]}

# test API
curl -X POST "https://api.telegram.org/botXXX:YYYY/sendMessage" -d "chat_id=-zzzzzzzzzz&text=my sample text"

curl -X POST "https://api.telegram.org/bot111111111:XXXXXXXXXXXXXXXXXXXX/sendMessage" -d "chat_id=-12345534343&text=my sample text"

# More details just follow this: https://velenux.wordpress.com/2022/09/12/how-to-configure-prometheus-alertmanager-to-send-alerts-to-telegram/
```

## Alertmanager 

Atividades:
- [X] Criado um evento de crashLoopBack
- [X] Criar um alerta e enviar a mensagem via telegram
- [X] Criar um alerta customizado no alertmanager

# Apply Alert Manager config

```bash
make deploy-email-local
make deploy-kube-prometheus-stack-local-alertmanagerconfigs
k apply -f apps/nginx 

curl -H 'Content-Type: application/json' -d '[{"labels":{"alertname":"myalert"}}]' \
    http://alertmanager.kubernetes.docker.internal/api/v1/alerts

curl -H 'Content-Type: application/json' -d '[{"labels":{"namespace":"kube-prometheus-stack"}}]' http://alertmanager.kubernetes.docker.internal/api/v1/alerts


# Access Mailhog 
- http://mailhog.kubernetes.docker.internal
- Internal DNS: email-mailhog.email.svc.cluster.local:1025

# deploy small alpine-based image to send mail test
kubectl apply -f https://raw.githubusercontent.com/fabianlee/tiny-tools-with-swaks/main/k8s-tiny-tools-with-swaks.yaml

kubectl exec -it deployment/tiny-tools-with-swaks -- /usr/bin/swaks -f image-test@me -t image@me -s "email-mailhog.email.svc.cluster.local" -p "1025" --body "this is a test" --header "Subject: cluster validation"

```
