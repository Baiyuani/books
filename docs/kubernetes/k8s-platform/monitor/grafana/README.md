---
tags: 
  - monitor
  - dashboard

---
# 部署grafana

## 使用helm部署

### [官方charts](https://github.com/grafana/helm-charts/tree/main/charts/grafana)

- [values.yaml](values.yaml)

```shell
kubectl create secret generic grafana-admin -n ops \
--from-literal=admin-user=admin \
--from-literal=admin-password='xxxx'

helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm upgrade --install grafana grafana/grafana \
--version 8.4.5 -n ops --create-namespace \
-f values.yaml
```

## dashboards

- [Node Exporter Full](https://grafana.com/grafana/dashboards/1860-node-exporter-full/)
- [Felix Dashboard (Calico)](https://grafana.com/grafana/dashboards/12175-felix-dashboard-calico/)
- [Loki stack monitoring (Promtail, Loki)](https://grafana.com/grafana/dashboards/14055-loki-stack-monitoring-promtail-loki/)
- [Blackbox Exporter (HTTP prober)](https://grafana.com/grafana/dashboards/13659-blackbox-exporter-http-prober/)
- [MinIO Dashboard](https://grafana.com/grafana/dashboards/13502-minio-dashboard/)
