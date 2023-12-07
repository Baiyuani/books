# 部署

> [bitnami charts](https://github.com/bitnami/charts/tree/dc8c5401abbd03e63ff102e120979faeba0ee365/bitnami/grafana)
- 如果helm安装失败，可以使用[yaml安装](https://grafana.com/docs/grafana/v9.0/setup-grafana/installation/kubernetes/)

## 1. install

```shell
helm repo add bitnami https://charts.bitnami.com/bitnami


# grafana
helm upgrade --install grafana bitnami/grafana -n prometheus  \
# --version=8.2.6 \
--version=9.1.0 \
--set global.storageClass='nfs-client'  \
--set persistence.size=10Gi \
--set ingress.enabled=true \
--set ingress.hostname=grafana.baiyuani.top \
--set ingress.ingressClassName=nginx \
--set admin.user='admin' \
--set admin.password='qhr732hguhfeu3u' 
```



## 2. 平台使用

- 访问grafana

- 配置Prometheus为数据源

```shell
#TODO
```

- 导入dashboard

[dashboards](dashboards)(需要到git仓库查看)


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

