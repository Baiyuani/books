# kube-prometheus-stack

> 20240816

- [doc](https://prometheus-operator.dev/docs/getting-started/installation)
- [charts](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)

## Prerequisites

- Kubernetes 1.19+
- Helm 3+


```shell
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

kubectl patch storageclass nfs-client -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

helm show values prometheus-community/kube-prometheus-stack --version 61.9.0

helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
--version 61.9.0 -n prometheus --create-namespace \
--set prometheusOperator.admissionWebhooks.patch.image.registry="registry.aliyuncs.com" \
--set prometheusOperator.admissionWebhooks.patch.image.repository="google_containers/kube-webhook-certgen" \
--set kube-state-metrics.image.registry="myifeng" \
--set kube-state-metrics.image.repository="registry.k8s.io_kube-state-metrics_kube-state-metrics" \
--set alertmanager.ingress.enabled=true \
--set grafana.ingress.enabled=true \
--set prometheus.ingress.enabled=true \
--set thanosRuler.ingress.enabled=true \
--set alertmanager.ingress.hosts[0]=alertmanager.local.domain \
--set grafana.ingress.hosts[0]=grafana.local.domain \
--set prometheus.ingress.hosts[0]=prometheus.local.domain \
--set thanosRuler.ingress.hosts[0]=thanosruler.local.domain 

```















