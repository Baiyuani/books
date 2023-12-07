https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-mysql-exporter


```shell
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm upgrade --install local-mysql-exporter prometheus-community/prometheus-mysql-exporter -n developer \
--set serviceMonitor.enabled='true' \
--set mysql.user='root' \
--set mysql.pass='qqq...123' \
--set mysql.host='192.168.0.204' \
--set mysql.port='3306'
```