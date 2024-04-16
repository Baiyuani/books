# local-path-provisioner

## 安装

https://github.com/rancher/local-path-provisioner

### 安装要求

k8s > 1.12

### 安装步骤

#### 1. 修改[local-path-storage.yaml](./local-path-storage.yaml)中的存储路径配置（会将该节点上pod使用local-path时的数据存放在该目录），以下为几种配置示例

- 默认路径（即没有为节点明确存储路径时，所有节点都使用该配置）

```yaml
data:
  config.json: |-
    {
            "nodePathMap":[
            {
                    "node":"DEFAULT_PATH_FOR_NON_LISTED_NODES",
                    "paths":["/opt/local-path-provisioner"]
            }
            ]
    }
```

- 为`k8s-node1`单独设置存储路径（即`k8s-node1`上的pod使用local-path时，将数据存储在`/data/local-path-provisioner`目录，其他节点使用默认配置）

```yaml
data:
  config.json: |-
    {
            "nodePathMap":[
            {
                    "node":"DEFAULT_PATH_FOR_NON_LISTED_NODES",
                    "paths":["/opt/local-path-provisioner"]
            },
            {
                    "node":"k8s-node1",
                    "paths":["/data/local-path-provisioner"]
            }
            ]
    }
```

- 集群中有两台运行数据库的节点，节点名称为`mariadb-primary`和`mariadb-secondary`，其他节点不提供local-path

```yaml
data:
  config.json: |-
    {
            "nodePathMap":[
            {
                    "node":"mariadb-primary",
                    "paths":["/data/local-path-provisioner"]
            },
            {
                    "node":"mariadb-secondary",
                    "paths":["/data/local-path-provisioner"]
            }
            ]
    }
```

#### 2. 执行安装

```shell
kubectl apply -f ./local-path-storage.yaml
```

注意：

- 使用了该存储的pod尽量避免随意调度，除非在部署该存储时针对每个node的存储做了配置。（即完全清楚数据将存储在哪里，避免意外的程序将磁盘写满导致故障）
- pvc创建后，不会立即绑定，仅当使用该pvc的pod被调度后，再从调度节点创建[`local`类型的pv](https://kubernetes.io/zh-cn/docs/concepts/storage/volumes/#local)。这是由storageClass的`volumeBindingMode: WaitForFirstConsumer`决定，不可修改
- local类型的pv会设置`nodeAffinity`字段，这要求使用该pv的pod必须调度到符合规则的节点。（即一定在pv被创建时pod所在节点，而不需要额外的配置来保证pod后续每次重启的调度）
