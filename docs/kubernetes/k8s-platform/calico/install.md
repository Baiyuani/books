---
tags:
  - k8s
  - calico
  - network
---
# calico部署

## 部署

### [系统要求](https://docs.tigera.io/calico/latest/getting-started/kubernetes/requirements)

- x86-64, arm64, ppc64le, or s390x processor

- Calico must be able to manage `cali*` interfaces on the host. When IPIP is enabled (the default), Calico also needs to be able to manage `tunl*` interfaces. When VXLAN is enabled, Calico also needs to be able to manage the `vxlan.calico` interface.

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

!!! note 

    以下官方提供的manifests，calico-vxlan.yaml均为`vxlanMode: CrossSubnet`，calico.yaml均为`ipipMode: Always`.

```bash
# 最新版
#vxlan
wget https://github.com/projectcalico/calico/blob/master/manifests/calico-vxlan.yaml
#ipip
wget https://github.com/projectcalico/calico/blob/master/manifests/calico.yaml
```

- 历史版本

> 修改版本和文件名即可。浏览器访问或下载或`kubectl create -f`

1. `<=v3.21`

   - `https://docs.projectcalico.org/archive/v3.15/manifests/calico-vxlan.yaml`

   - `https://docs.projectcalico.org/archive/v3.15/manifests/calico.yaml`

2. `v3.22 <= version <= v3.25`

   - `https://docs.tigera.io/archive/v3.22/manifests/calico.yaml`

3. `>= v3.26`

   - `https://github.com/projectcalico/calico/blob/v3.24.4/manifests/calico.yaml`

