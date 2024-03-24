# how to

1. create a secret

    kubectl create namespace database

    kubectl create secret generic mssql --from-literal=MSSQL_SA_PASSWORD="MyC0m9l&xP@ssw0rd" -n database


2. connect

```bash
# from remote system
sqlcmd -S 10.3.2.4 -U SA -P '<YourPassword>'
# exec in container/pod
/opt/mssql-tools18/bin/sqlcmd -S localhost -U SA -P '<YourPassword>'
```
