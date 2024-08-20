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

- 创建ceph集群[cluster-test.yaml](https://github.com/rook/rook/blob/release-1.14/deploy/examples/cluster-test.yaml)

```shell
kubectl create -f cluster-test.yaml
```

- 块存储，创建存储类[storageclass-test.yaml](https://github.com/rook/rook/blob/release-1.14/deploy/examples/csi/rbd/storageclass-test.yaml)

- [块存储使用示例](https://github.com/rook/rook/tree/release-1.14/deploy/examples/csi/rbd)

- 创建文件系统存储[filesystem-test.yaml](https://github.com/rook/rook/blob/release-1.14/deploy/examples/filesystem-test.yaml)

- 创建文件系统存储类[storageclass.yaml](https://github.com/rook/rook/blob/release-1.14/deploy/examples/csi/cephfs/storageclass.yaml)

- [文件系统存储使用示例](https://github.com/rook/rook/tree/release-1.14/deploy/examples/csi/cephfs)


