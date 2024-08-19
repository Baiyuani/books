# kube-prometheus-stack

> 20240816

- [doc](https://prometheus-operator.dev/docs/getting-started/installation)
- [charts](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)

## Prerequisites

- Kubernetes 1.19+
- Helm 3+

## Install

- [values.yaml](values.yaml)
- [values-origin-61.9.0.yaml](values-origin-61.9.0.yaml)

```shell
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

#kubectl patch storageclass nfs-client -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

helm show values prometheus-community/kube-prometheus-stack --version 61.9.0
```

- 安装

```shell
kubectl create secret generic grafana-admin -n ops \
--from-literal=admin-user=admin \
--from-literal=admin-password='xxxx'

helm upgrade --install kube-prometheus-stack \
prometheus-community/kube-prometheus-stack \
--version 61.9.0 -n ops --create-namespace \
-f values.yaml
```

- grafana单独安装

[grafana](../grafana)

```shell
helm upgrade --install kube-prometheus-stack \
prometheus-community/kube-prometheus-stack \
--version 61.9.0 -n ops --create-namespace \
--set grafana.enabled=false \
--set grafana.forceDeployDatasources=true \
--set grafana.forceDeployDashboards=true \
-f values.yaml
```

- thanos

```shell
--set thanosRuler.enabled=true \
--set thanosRuler.ingress.enabled=true \
--set thanosRuler.ingress.hosts[0]=thanosruler.local.domain \
--set thanosRuler.thanosRulerSpec.replicas=1
```
