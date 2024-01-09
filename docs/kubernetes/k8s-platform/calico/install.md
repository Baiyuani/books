---
tags:
  - k8s
  - calico
  - network
---
# calico部署

## 部署

### [系统要求](https://docs.tigera.io/calico/latest/getting-started/kubernetes/requirements)

- 端口要求

  | 配置                           | 主机                   | 连接类型             | 端口/协议               |
  |------------------------------|----------------------|------------------|---------------------|
  | Calico网络 (BGP)	              | 全部	                  | 双向               | TCP 179             |
  | 启用 IP-in-IP 的Calico网络（默认）    | 全部                   | 双向               | 	IP-in-IP，通常由其协议号表示4 |
  | 启用 VXLAN 的Calico网络           | 全部                   | 双向               | UDP 4789            |
  | 启用 Typha 的Calico网络           | Typha agent hosts    | 传入               | TCP 5473（默认）        |
  | 启用 IPv4 Wireguard 的Calico网络  | 	全部	| 双向| 	UDP 51820（默认）      |
  | 启用 IPv6 Wireguard 的Calico网络	 | 全部	| 双向	| UDP 51821（默认）       |
  | Flannel (VXLAN)	             | 全部	                  | 双向	              | UDP 4789            |
  | 全部	                          | kube-apiserver 主机    | 	传入	             | 通常是 TCP 443 或 6443  |
  | etcd 数据存储	                   | etcd 主机	             | 传入	              | TCP 2379 但可能有所不同    |


### 使用tigera operator

- 安装operator
    ```shell
    kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/tigera-operator.yaml
    ```

- 部署，自定义配置[参考](https://docs.tigera.io/calico/latest/getting-started/kubernetes/self-managed-onprem/config-options)
    ```shell
    kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/custom-resources.yaml
    ```

  [完整参考](https://docs.tigera.io/calico/latest/reference/installation/api)

### 使用helm部署

> 官方文档：https://projectcalico.docs.tigera.io/getting-started/kubernetes/helm

```bash
helm repo add projectcalico https://docs.tigera.io/calico/charts
helm repo update

helm show values projectcalico/tigera-operator --version v3.26.4

kubectl create namespace tigera-operator
helm install calico projectcalico/tigera-operator --version v3.26.4 --namespace tigera-operator

watch kubectl get pods -n calico-system
```

### 使用yaml manifests部署(不建议使用，可以对底层 Kubernetes 资源进行高度特定修改时使用)

- 新版3.26.3

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
