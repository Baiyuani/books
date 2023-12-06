[prometheus社区charts](https://github.com/prometheus-community/helm-charts/tree/main/charts)

## kube-prometheus-stack

```shell
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update


helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack -n prometheus

helm install prometheus prometheus-community/prometheus -n prometheus
```

