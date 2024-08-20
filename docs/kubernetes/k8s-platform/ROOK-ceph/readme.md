# 

> v1.14

## 安装

### [Ceph Operator](https://rook.io/docs/rook/latest-release/Helm-Charts/operator-chart/)

#### Prerequisites

- Kubernetes 1.22+
- Helm 3.x

#### Install

- [v1.14-origin-values.yaml](v1.14-origin-values.yaml)

```shell
helm repo add rook-release https://charts.rook.io/release
helm install rook-ceph rook-release/rook-ceph -f values.yaml \
--create-namespace --namespace rook-ceph 
```

### Ceph Cluster

> 使用`helm chart`安装集群，或者参考`manifests`中的清单手工配置

#### [Ceph Cluster Chart](https://rook.io/docs/rook/latest-release/Helm-Charts/ceph-cluster-chart/)

TODO

#### [Ceph Cluster manifests](https://rook.io/docs/rook/latest-release/Getting-Started/example-configurations/)

> 所有示例清单[example-manifests](https://github.com/rook/rook/tree/release-1.14/deploy/examples)
>
> 如下为测试用例

- [cluster-test.yaml](manifests/cluster-test.yaml)

```shell
kubectl create -f cluster-test.yaml
```

- 块存储[storageclass-test.yaml](manifests%2Fstorageclass-test.yaml)

- 文件系统存储[filesystem-test.yaml](manifests%2Ffilesystem-test.yaml)

