# calico

## 使用helm部署

> 官方文档：https://projectcalico.docs.tigera.io/getting-started/kubernetes/helm


```bash
helm repo add projectcalico https://projectcalico.docs.tigera.io/charts
helm repo update
helm install calico projectcalico/tigera-operator --version v3.22.0

helm show values projectcalico/tigera-operator --version v3.22.0
```

## 使用yaml部署

- 新版

[calico.yaml](calico.yaml)
[calico-vxlan.yaml](calico-vxlan.yaml)

- 历史版本

[calico-3.22.3.yaml](calico-3.22.3.yaml)
[calico-vxlan-3.22.3.yaml](calico-vxlan-3.22.3.yaml)
[calico-vxlan-3.19.1.yaml](calico-vxlan-3.19.1.yaml)


```bash
#calico版本是v3.19.1
kubectl apply -f calico-vxlan-3.19.1.yaml

# 最新版20220528
#vxlan
wget https://github.com/projectcalico/calico/blob/master/manifests/calico-vxlan.yaml
#ipip模式
wget https://github.com/projectcalico/calico/blob/master/manifests/calico.yaml
```
