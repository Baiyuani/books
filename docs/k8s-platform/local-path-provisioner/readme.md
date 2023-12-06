https://github.com/rancher/local-path-provisioner

k8s > 1.12

```shell
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.24/deploy/local-path-storage.yaml
```

注意：

- 使用了该存储的pod尽量避免随意调度，除非在部署该存储时针对每个node的存储做了配置。（即完全清楚数据将存储在哪里，避免意外的程序将磁盘写满导致故障）
- pvc创建后，不会立即绑定，仅当使用该pvc的pod被调度后，再从调度节点创建[`local`类型的pv](https://kubernetes.io/zh-cn/docs/concepts/storage/volumes/#local)。这是由storageClass的`volumeBindingMode: WaitForFirstConsumer`决定，不可修改
- local类型的pv会设置`nodeAffinity`字段，这要求使用该pv的pod必须调度到符合规则的节点。（即一定在pv被创建时pod所在节点，而不需要额外的配置来保证pod后续每次重启的调度）
