允许卷扩展

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: standard
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp2
reclaimPolicy: Retain
allowVolumeExpansion: true
mountOptions:
  - debug
volumeBindingMode: Immediate
```


特性状态： Kubernetes v1.11 [beta]
PersistentVolume 可以配置为可扩展。将此功能设置为 true 时，允许用户通过编辑相应的 PVC 对象来调整卷大小。

当下层 StorageClass 的 allowVolumeExpansion 字段设置为 true 时，以下类型的卷支持卷扩展。

卷类型	Kubernetes 版本要求
gcePersistentDisk	1.11
awsElasticBlockStore	1.11
Cinder	1.11
glusterfs	1.11
rbd	1.11
Azure File	1.11
Azure Disk	1.11
Portworx	1.11
FlexVolume	1.13
CSI	1.14 (alpha), 1.16 (beta)
说明： 此功能仅可用于扩容卷，不能用于缩小卷。



Ref:
[storageclass支持动态扩容的存储类型](https://kubernetes.io/zh-cn/docs/concepts/storage/storage-classes/)
[kubernetes中用NFS做后端存储支不支持PVC扩容？不支持](https://cloud.tencent.com/developer/article/1602852)
