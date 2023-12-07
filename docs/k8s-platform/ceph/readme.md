# Rook

## rook安装测试

- [官方安装手册](https://rook.io/docs/rook/v1.9/quickstart.html)
- [代码地址](https://github.com/rook/rook/tree/v1.9.13)
- [操作参考](https://cloud.tencent.com/developer/article/2000584)
- [重置环境](https://rook.io/docs/rook/v1.9/ceph-teardown.html#zapping-devices)
- [常见问题](https://rook.io/docs/rook/v1.9/ceph-common-issues.html#osd-pods-are-not-created-on-my-devices)


#### Minimum Version
Kubernetes v1.17 or higher is supported by Rook.

#### Prerequisites
To make sure you have a Kubernetes cluster that is ready for Rook, you can follow these instructions.

In order to configure the Ceph storage cluster, at least one of these local storage options are required:

Raw devices (no partitions or formatted filesystems)
This requires lvm2 to be installed on the host. To avoid this dependency, you can create a single full-disk partition on the disk (see below)
Raw partitions (no formatted filesystem)
Persistent Volumes available from a storage class in block mode

## 安装

```shell
# 拉取代码
git clone --single-branch --branch v1.9.13 https://github.com/rook/rook.git
# 安装operator
cd rook/deploy/examples
kubectl create -f crds.yaml -f common.yaml -f operator.yaml
# 需要等待operator运行
kubectl get pod -n rook-ceph

#需要注意的是，官方的部署镜像默认都是从k8s.gcr.io或者quay.io拉取，这里建议修改下operator.yaml的镜像名称，从dockerhub拉取，operator.yaml的镜像字段配置默认都是注释的，需要修改yaml文件去掉注释，然后配置下dockerhub上的镜像，修改后如下。
[root@VM-0-4-centos examples]# cat operator.yaml | grep -i image:
  ROOK_CSI_CEPH_IMAGE: "cnplat/cephcsi:v3.5.1"
  ROOK_CSI_REGISTRAR_IMAGE: "opsdockerimage/sig-storage-csi-node-driver-registrar:v2.5.0"
  ROOK_CSI_RESIZER_IMAGE: "opsdockerimage/sig-storage-csi-resizer:v1.4.0"
  ROOK_CSI_PROVISIONER_IMAGE: "opsdockerimage/sig-storage-csi-provisioner:v3.1.0"
  ROOK_CSI_SNAPSHOTTER_IMAGE: "opsdockerimage/sig-storage-csi-snapshotter:v5.0.1"
  ROOK_CSI_ATTACHER_IMAGE: "opsdockerimage/sig-storage-csi-attacher:v3.4.0"
  # ROOK_CSI_NFS_IMAGE: "k8s.gcr.io/sig-storage/nfsplugin:v3.1.0"
  # CSI_VOLUME_REPLICATION_IMAGE: "quay.io/csiaddons/volumereplication-operator:v0.3.0"
  ROOK_CSIADDONS_IMAGE: "willdockerhub/k8s-sidecar:v0.2.1"
          image: rook/ceph:v1.9.2



vim cluster.yaml
    spec:
      dashboard:
        urlPrefix: /ceph-dashboard
        port: 80
        ssl: false

# 创建ceph集群
kubectl create -f cluster.yaml

kubectl get po -n rook-ceph 

    NAME                                                    READY   STATUS      RESTARTS   AGE
    csi-cephfsplugin-db874                                  2/2     Running     0          44m
    csi-cephfsplugin-gx494                                  2/2     Running     0          44m
    csi-cephfsplugin-j4crv                                  2/2     Running     0          44m
    csi-cephfsplugin-provisioner-69db968597-7gd9z           5/5     Running     0          44m
    csi-cephfsplugin-provisioner-69db968597-wmd2j           5/5     Running     0          44m
    csi-rbdplugin-2678w                                     2/2     Running     0          44m
    csi-rbdplugin-88zp6                                     2/2     Running     0          44m
    csi-rbdplugin-pd6ph                                     2/2     Running     0          44m
    csi-rbdplugin-provisioner-8f4c9744d-gxfdx               5/5     Running     0          44m
    csi-rbdplugin-provisioner-8f4c9744d-zfl4d               5/5     Running     0          44m
    rook-ceph-crashcollector-k8s-master1-6475bddb6c-br8mp   1/1     Running     0          29m
    rook-ceph-crashcollector-k8s-node1-685449647f-xx6nt     1/1     Running     0          40m
    rook-ceph-crashcollector-k8s-node2-8ddf7c7bd-22ktp      1/1     Running     0          29m
    rook-ceph-mds-myfs-a-76ff75746d-cdh84                   1/1     Running     0          29m
    rook-ceph-mds-myfs-b-f57ccb9b8-mrpt7                    1/1     Running     0          29m
    rook-ceph-mgr-a-844b5c6785-shpbw                        2/2     Running     0          42m
    rook-ceph-mgr-b-7cf45b98f9-2mphj                        2/2     Running     0          42m
    rook-ceph-mon-a-ff6f44777-dnsr2                         1/1     Running     0          44m
    rook-ceph-mon-b-6986d5c8d-lqnbt                         1/1     Running     0          43m
    rook-ceph-mon-c-554b78677f-7lccm                        1/1     Running     0          43m
    rook-ceph-operator-b45b4db68-bs69t                      1/1     Running     0          74m
    rook-ceph-osd-0-7d85c984fb-knkrx                        1/1     Running     0          40m
    rook-ceph-osd-1-864757ff78-ckx75                        1/1     Running     0          40m
    rook-ceph-osd-2-6f76c78ff5-6hwl8                        1/1     Running     0          40m
    rook-ceph-osd-prepare-k8s-master1-4fsjd                 0/1     Completed   0          40m
    rook-ceph-osd-prepare-k8s-node1-f6sct                   0/1     Completed   0          40m
    rook-ceph-osd-prepare-k8s-node2-pwmp9                   0/1     Completed   0          40m
    rook-ceph-tools-697bd5f4f7-2zlgz                        1/1     Running     0          39m


# 安装ceph-tools的客户端工具
kubectl create -f deploy/examples/toolbox.yaml
kubectl -n rook-ceph exec -it deploy/rook-ceph-tools -- bash

ceph status

     cluster:
       id:     a0452c76-30d9-4c1a-a948-5d8405f19a7c
       health: HEALTH_OK
    
     services:
       mon: 3 daemons, quorum a,b,c (age 3m)
       mgr: a(active, since 2m)
       osd: 3 osds: 3 up (since 1m), 3 in (since 1m)
    ...



```

- 创建ingress，以便使用域名访问dashboard

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ceph-ingress
  namespace: rook-ceph
spec:
  ingressClassName: nginx
  rules:
  - host: ceph.local.domain
    http:
      paths:
      - backend:
          service:
            name: rook-ceph-mgr-dashboard
            port:
              number: 80
        path: /
        pathType: ImplementationSpecific  
```

- 获取管理员密码
```shell
kubectl -n rook-ceph get secret rook-ceph-dashboard-password -o jsonpath="{['data']['password']}" | base64 --decode && echo
```

## cephFileSystem测试

```shell
# 创建CephFilesystem
kubectl apply -f examples/filesystem.yaml

# 查看
kubectl -n rook-ceph exec -it deploy/rook-ceph-tools -- bash
ceph fs ls
name: myfs, metadata pool: myfs-metadata, data pools: [myfs-replicated ]

# 创建sc
kubectl apply -f deploy/examples/csi/cephfs/storageclass.yaml

# 创建pvc测试，显示bound，则说明创建成功
kubectl apply -f deploy/examples/csi/cephfs/pvc.yam
```

## rbd测试

```shell
# 创建一个rbdsc，同时也会创建一个rbd的pool
kubectl create -f deploy/examples/csi/rbd/storageclass.yaml

# 创建pvc测试，显示bound，则说明创建成功
kubectl create -f deploy/examples/csi/rbd/pvc.yaml
```


## 使用测试

```shell
kubectl create -f deploy/examples/mysql.yaml
kubectl create -f deploy/examples/wordpress.yaml


# charts测试
helm upgrade --install demo . \
--set persistence.enabled='true' \
--set persistence.storageClass='rook-ceph-block' \
--set persistence.mountPath='/var/log/nginx' \
--set persistence.size='1Gi' \
--set persistence.accessModes[0]='ReadWriteOnce'
```