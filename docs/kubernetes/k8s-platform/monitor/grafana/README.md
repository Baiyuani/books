---
tags: 
  - monitor
  - dashboard

---
# 部署grafana

## 使用helm部署

### [官方charts](https://github.com/grafana/helm-charts/tree/main/charts/grafana)

```shell
kubectl create secret generic grafana-admin -n prometheus \
--from-literal=admin-user=admin \
--from-literal=admin-password='xxxx'

helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm upgrade --install grafana grafana/grafana -n prometheus \
--version 7.3.7 \
--set ingress.enabled=true \
--set ingress.hosts[0]='grafana.site.domain' \
--set ingress.ingressClassName=nginx \
--set persistence.enabled=true \
--set persistence.storageClassName='nfs-client'  \
--set initChownData.enabled=false \
--set admin.existingSecret=grafana-admin 
```

## 平台使用

- 访问grafana

- 配置Prometheus为数据源

```shell
#TODO
```

- 导入dashboard

[dashboards](https://github.com/Baiyuani/books/tree/main/docs/kubernetes/k8s-platform/monitor/grafana/dashboards)


| ID  | Description | Data origin | 
|-----|-------------|-------------|
|  8919   |   1 Node Exporter Dashboard 22/04/13 ConsulManager自动同步版           | node        |
|  1860   |   Node Exporter Full           | node        |
| 3125    |    Docker monitoring - alicek106 revision         | docker      |
| 315    |     Kubernetes cluster monitoring (via Prometheus)        | k8s         |
| 15661    | 1 K8S for Prometheus Dashboard 20211010 EN            | k8s         |
|  10000   |   Cluster Monitoring for Kubernetes          | k8s         |
|  14518   |   Kubernetes Cluster Overall Dashboard          | k8s         |
|9614| NGINX Ingress controller| nginx-ingress-controller|
|12006| Kubernetes apiserver| apiserver|
|7587|Prometheus Blackbox Exporter|blackbox|
|13659|Blackbox Exporter (HTTP prober)|blckbox|
|14928|Prometheus Blackbox Exporter| blackbox|
|15760  | Kubernetes / Views / Pods | pods|
