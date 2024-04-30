# 部署

## 部署rancher

**注意：rancher对集群可能有影响，正式环境安装请以危险操作看待，通知项目，约定操作时间**

## helm部署（建议）

[Rancher Helm Chart Options](https://ranchermanager.docs.rancher.com/v2.6/getting-started/installation-and-upgrade/installation-references/helm-chart-options)

```bash
helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
helm upgrade --install rancher rancher-stable/rancher \
-n cattle-system --create-namespace \
--version=2.6.14 \
--set hostname=rancher.local.domain \
--set ingress.tls.source=secret \
--set bootstrapPassword='xxxxxxx' \
--set replicas=1
```

## yaml部署（不建议）

[rancher.yaml](rancher.yaml)

```bash
kubectl create ns rancher
kubectl -n rancher create serviceaccount rancher 
kubectl create clusterrolebinding rancher --clusterrole=cluster-admin --serviceaccount=rancher:rancher 
kubectl apply -f rancher.yaml
```

## 卸载rancher

不能直接删除rancher，使用该脚本删除：https://github.com/rancher/rancher-cleanup

