## 为tidb配置下游数据库，接收数据同步

https://docs.pingcap.com/zh/tidb/dev/replicate-between-primary-and-secondary-clusters


#### [注意事项](https://docs.pingcap.com/zh/tidb/stable/ticdc-overview#%E6%9C%80%E4%BD%B3%E5%AE%9E%E8%B7%B5)

    TiCDC 同步的表需要至少存在一个有效索引的表，有效索引的定义如下：

    主键 (PRIMARY KEY) 为有效索引。
    唯一索引 (UNIQUE INDEX) 中每一列在表结构中明确定义非空 (NOT NULL) 且不存在虚拟生成列 (VIRTUAL GENERATED COLUMNS)。

- 开启[同步没有有效索引的表](https://docs.pingcap.com/zh/tidb/stable/ticdc-manage-changefeed#%E5%90%8C%E6%AD%A5%E6%B2%A1%E6%9C%89%E6%9C%89%E6%95%88%E7%B4%A2%E5%BC%95%E7%9A%84%E8%A1%A8)


#### [上游tidb部署ticdc](https://docs.pingcap.com/zh/tidb-in-kubernetes/stable/deploy-ticdc)

- 1. 修改[tidb-cluster.yaml](./manifests/tidb-cluster.yaml)，ticdc部分

```yaml
  ## TiCDC is a tool for replicating the incremental data of TiDB
  ## Ref: https://docs.pingcap.com/tidb-in-kubernetes/stable/deploy-ticdc/
  ticdc:
    baseImage: pingcap/ticdc
  #   version: "v6.5.0"
    replicas: 3
    storageClassName: local-path
  #   requests:
  #     cpu: 1000m
  #     memory: 1Gi
  #   limits:
  #     cpu: 2000m
  #     memory: 2Gi
  #   imagePullPolicy: IfNotPresent
  #   imagePullSecrets:
  #   - name: secretName
  #   hostNetwork: false
  #   serviceAccount: advanced-tidb-ticdc
  #   priorityClassName: system-cluster-critical
  #   schedulerName: default-scheduler
  #   nodeSelector:
  #     app.kubernetes.io/component: ticdc
  #   annotations:
  #     node.kubernetes.io/instance-type: some-vm-type
  #   tolerations: {}
  #   configUpdateStrategy: RollingUpdate
  #   statefulSetUpdateStrategy: RollingUpdate
  #   podSecurityContext: {}
  #   env: []
  #   additionalContainers: []
  #   storageVolumes: []
  #   additionalVolumes: []
  #   additionalVolumeMounts: []
  #   terminationGracePeriodSeconds: 30
  #   config: |
  #     gc-ttl = 86400
  #     log-level = "info"
  #     log-file = ""
  #   # TopologySpreadConstraints for pod scheduling, will overwrite cluster level spread constraints setting
  #   # Ref: pkg/apis/pingcap/v1alpha1/types.go#TopologySpreadConstraint
  #   topologySpreadConstraints:
  #   - topologyKey: topology.kubernetes.io/zone
```

#### 下游tidb部署

> 注意：默认情况下，不允许从tidb和主tidb共用k8s节点(如果一定要共用需要同时去掉主从tidb的podAntiAffinity相关配置)

使用[tidb-cluster.yaml](./manifests/tidb-cluster.yaml)，修改`name`和`nodeSelector`或其他配置后`kubectl create -f`。不需要开启ticdc

```shell
# 示例中从tidb为单机模式，额外使用了一个k8s节点
kubectl create -f ./manifest/slave-tidb-cluster.yaml
kubectl create secret generic slave-tidb-secret --from-literal=root="1qaz@WSX" --namespace=tidb
kubectl create -f ./manifest/slave-tidb-init.yaml
```

#### 使用BR迁移全量数据(如果是全新的tidb，即不需要迁移数据，则这一步跳过)

- 上游执行

```sql
SET GLOBAL tidb_gc_enable=FALSE;
SELECT @@global.tidb_gc_enable;
-- BackupTS 作为数据校验截止时间和 TiCDC 增量扫描的开始时间
BACKUP DATABASE * TO 'local:///tmp/backup/' RATE_LIMIT = 120 MB/SECOND;
+----------------------+----------+--------------------+---------------------+---------------------+
| Destination          | Size     | BackupTS           | Queue Time          | Execution Time      |
+----------------------+----------+--------------------+---------------------+---------------------+
| local:///tmp/backup/ | 10315858 | 431434047157698561 | 2022-02-25 19:57:59 | 2022-02-25 19:57:59 |
+----------------------+----------+--------------------+---------------------+---------------------+
1 row in set (2.11 sec)
```

- 下游执行

```sql
RESTORE DATABASE * FROM 'local:///tmp/backup/';
+----------------------+----------+--------------------+---------------------+---------------------+
| Destination          | Size     | BackupTS           | Queue Time          | Execution Time      |
+----------------------+----------+--------------------+---------------------+---------------------+
| local:///tmp/backup/ | 10315858 | 431434141450371074 | 2022-02-25 20:03:59 | 2022-02-25 20:03:59 |
+----------------------+----------+--------------------+---------------------+---------------------+
1 row in set (41.85 sec)
```



#### [创建同步任务](https://docs.pingcap.com/zh/tidb/stable/ticdc-sink-to-mysql#sink-uri-%E9%85%8D%E7%BD%AE-mysqltidb)

- 登录任意ticdc的pod，创建同步任务。命令参数可参考上面链接文档

如果执行了上一步的数据迁移，则需要在创建同步任务命令中添加参数`--start-ts`，填上一步中上游集群备份数据时输出的`BackupTS`

```shell
# 创建同步任务
/cdc cli changefeed create \
    --server=http://localhost:8301 \
    --sink-uri="mysql://root:MXFhekBXU1g=@slave-tidb-tidb:4000/" \
    --changefeed-id="simple-replication-task"

# 创建同步任务旧版，上面命令报错pd链接错误时可尝试
/cdc cli changefeed create \
    --pd=http://advanced-tidb-pd:2379 \
    --sink-uri="mysql://root:MXFhekBXU1g=@slave-tidb-tidb:4000/" \
    --changefeed-id="simple-replication-task"

# 数据迁移时添加参数--start-ts
/cdc cli changefeed create \
    --start-ts="431434047157698561" \
    --pd=http://advanced-tidb-pd:2379 \
    --sink-uri="mysql://root:MXFhekBXU1g=@slave-tidb-tidb:4000/" \
    --changefeed-id="simple-replication-task"
```


- 常用操作

```shell
# 查询同步列表
/cdc cli changefeed list --server=http://localhost:8301

# 删除同步任务
/cdc cli changefeed remove --server=http://localhost:8301 --changefeed-id simple-replication-task
```

#### 同步测试，在上游做写操作，观察下游是否同步