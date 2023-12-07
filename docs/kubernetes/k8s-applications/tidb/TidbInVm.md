# 虚拟化部署Tidb


[软件和硬件环境建议配置](https://docs.pingcap.com/zh/tidb/stable/hardware-and-software-requirements)


## 1. 服务器拓扑规划

高可用最小配置：使用3个节点，每个节点均负责运行所有组件，各组件间均匀分布在3个节点上组成高可用

参考[config-templates/simple.yaml](config-templates/simple.yaml)



## 2. [TiDB 环境与系统配置检查](https://docs.pingcap.com/zh/tidb/stable/check-before-deployment)

按照标题链接文档初始化服务器及ssh免密

## 3. [使用tiup部署](https://docs.pingcap.com/zh/tidb/stable/production-deployment-using-tiup)

- 部署并启动

[simple.yaml](config-templates/simple.yaml)

```shell
# 安装tiup
curl --proto '=https' --tlsv1.2 -sSf https://tiup-mirrors.pingcap.com/install.sh | sh

source .bash_profile
which tiup

# 安装 TiUP cluster 组件
tiup cluster

# 安装前检查
tiup cluster check config-templates/simple.yaml --user root 
# 修复
tiup cluster check config-templates/simple.yaml --apply --user root 
# 部署。tidb-test为集群名称
tiup cluster deploy tidb-test v7.1.0 config-templates/simple.yaml --user root 

# 安装完成以后需要启动集群
tiup cluster start tidb-test --init
```

- 常用命令

```shell
# 查看集群列表
tiup cluster list

# 查看集群
tiup cluster display tidb-test
```


## 4. 离线部署

https://docs.pingcap.com/zh/tidb/stable/production-deployment-using-tiup#%E7%A6%BB%E7%BA%BF%E9%83%A8%E7%BD%B2


## 5. dashboard


通过`{pd-ip}:{pd-port}/dashboard`登录 TiDB Dashboard
