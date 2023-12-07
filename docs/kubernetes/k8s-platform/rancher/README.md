# 部署rancher


## yaml部署

[rancher.yaml](rancher.yaml)

```bash
kubectl create ns rancher
kubectl -n rancher create serviceaccount rancher 
kubectl create clusterrolebinding rancher --clusterrole=cluster-admin --serviceaccount=rancher:rancher 
kubectl apply -f rancher.yaml
```

## helm部署

```bash
helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
helm repo add rancher-mirror http://rancher-mirror.oss-cn-beijing.aliyuncs.com/server-charts/stable
# https://rancher.com/docs/rancher/v2.6/en/installation/install-rancher-on-k8s/chart-options/
helm upgrade --install rancher rancher-stable/rancher \
-n cattle-system --create-namespace \
--set hostname=rancher.local.domain \
--set ingress.tls.source=secret \
--set bootstrapPassword='123qqq...A' \
--set replicas=1


helm upgrade --install rancher rancher-stable/rancher \
-n cattle-system --create-namespace \
--version=2.6.11 \
--set hostname=rancher.site.domain \
--set ingress.tls.source=letsEncrypt \
--set replicas=1
```

