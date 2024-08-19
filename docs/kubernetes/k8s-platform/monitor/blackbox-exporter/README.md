# [blackbox-exporter](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-blackbox-exporter)

- [values.yaml](values.yaml)

```shell
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm upgrade --install kube-prometheus-stack-blackbox-exporter \
prometheus-community/prometheus-blackbox-exporter \
-n ops --create-namespace \
-f values.yaml
```
