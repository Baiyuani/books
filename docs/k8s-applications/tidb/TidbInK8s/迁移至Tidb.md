# 迁移至Tidb

有两种方案：

  1. 从mysql/mariadb导出sql文件，再导入tidb
  2. 使用TiDB Data Migration迁移工具，可全量或增量迁移数据


## 一、 从mairadb导出sql文件，再导入tidb

> 使用[dumpling](https://docs.pingcap.com/zh/tidb/v6.5/dumpling-overview)导出mariadb的数据，使用[lightning](https://docs.pingcap.com/zh/tidb/v6.5/tidb-lightning-overview)将数据导入tidb


#### 1. 从mysql/mariadb导出

- 在线安装dumpling

```shell
# 安装tiup
curl --proto '=https' --tlsv1.2 -sSf https://tiup-mirrors.pingcap.com/install.sh | sh
source $HOME/.bashrc

# 安装dumpling
tiup install dumpling

# 如果使用tiup安装dumpling，则使用以下命令，如果直接安装的dumpling，直接使用dumpling
tiup dumpling -u root -p '1qaz@WSX' -P 3306 -h 10.96.46.185 --filetype sql -t 8 -o /tmp/mariadb -r 200000 -F256MiB
```


- 离线安装

[下载工具包](https://cn.pingcap.com/product-community/)  


- 导出数据为sql文件
 
```shell
# 忽略了系统库
$ tiup dumpling -u root -p '1qaz@WSX' -P 3306 -h 10.96.46.185 --filetype sql -t 8 -o /tmp/mariadb -r 200000 -F256MiB

# 查看导出的文件
$ ls /tmp/mariadb
maria1-mb4.r1.0000000000000.sql  maria1-mb4-schema-create.sql      maria2-utf8.r2-schema.sql      metadata                       test-schema-create.sql
maria1-mb4.r1-schema.sql         maria2-utf8.r2.0000000000000.sql  maria2-utf8-schema-create.sql  my_database-schema-create.sql

```


#### 2. 导入tidb

- 获取values文件


```shell
# 获取values文件
helm inspect values pingcap/tidb-lightning > tidb-lightning-values.yaml
```

- 修改values


```yaml
dataSource:
  # 将dumpling导出的数据目录复制到集群的一个woker节点的/tmp/mariadb。nodeName应该填写该node的nodeName。
  # 如下配置会使lightning运行在k8s-node1上，并且将主机上的/tmp/mariadb挂载进容器中
  local: 
    nodeName: k8s-node1
    hostPath: /tmp/mariadb


targetTidbCluster:
  # tidb集群名称，填写tidb-cluster.yaml中定义的metadata.name
  name: advanced-tidb
  # tidb集群所在namespace
  namespace: "tidb"
  # 链接tidb所使用的用户
  user: root
  # 这个用户的密码来源于哪个secret
  secretName: tidb-secret
  # secret中，该用户密码的key
  secretPwdKey: root
```





- [k8s中安装lightning](https://docs.pingcap.com/zh/tidb-in-kubernetes/stable/restore-data-using-tidb-lightning)

lightning安装后会产生一个job，只运行一次

```shell
# 安装lightning
helm install advanced-tidb-lightning pingcap/tidb-lightning -n tidb --set failFast=true -f tidb-lightning-values.yaml 

# 安装以后产生lightning的job，可查看job日志确认导入进度
kubectl get job -n tidb

# 成功的日志
[2023/07/06 07:25:25.721 +00:00] [INFO] [import.go:1601] ["restore all tables data completed"] [takeTime=3.688287278s] []
[2023/07/06 07:25:25.721 +00:00] [INFO] [import.go:1604] ["cleanup task metas"]
[2023/07/06 07:25:25.723 +00:00] [INFO] [import.go:1221] ["everything imported, stopping periodic actions"]
[2023/07/06 07:25:25.727 +00:00] [INFO] [import.go:1909] ["skip full compaction"]
[2023/07/06 07:25:25.727 +00:00] [INFO] [import.go:2099] ["clean checkpoints start"] [keepAfterSuccess=remove] [taskID=1688628319580476994]
[2023/07/06 07:25:25.727 +00:00] [INFO] [import.go:2107] ["clean checkpoints completed"] [keepAfterSuccess=remove] [taskID=1688628319580476994] [takeTime=33.199µs] []
[2023/07/06 07:25:25.727 +00:00] [INFO] [import.go:514] ["the whole procedure completed"] [takeTime=5.806939726s] []
[2023/07/06 07:25:25.727 +00:00] [WARN] [local.go:780] ["remove local db file failed"] [error="unlinkat /var/lib/sorted-kv: device or resource busy"]
[2023/07/06 07:25:25.730 +00:00] [INFO] [main.go:106] ["tidb lightning exit"] [finished=true]
tidb lightning exit successfully

# 登录tidb，确认导入的数据存在

# lightning成功导入数据后，删除lightning 
helm uninstall advanced-tidb-lightning -n tidb
```


## 二、 使用TiDB Data Migration迁移数据

#### 1. [安装dm](https://docs.pingcap.com/zh/tidb-in-kubernetes/stable/deploy-tidb-dm)

```shell
kubectl create -f ./manifests/dm-cluster.yaml
```


#### 2. [创建dm任务](https://docs.pingcap.com/zh/tidb-in-kubernetes/stable/use-tidb-dm)

待补充