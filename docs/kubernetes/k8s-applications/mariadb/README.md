
# Mariadb

> 文档分为部署和备份两部分，操作时请不要遗漏备份

## 部署

> 标准安装要求使用helm部署

### 一、helm部署

- [charts](https://github.com/bitnami/charts/tree/db82355a553763690aad85629120e97976ca396b/bitnami/mariadb)

#### 0. 准备工作

- 需要可用的存储类，生产环境要求使用`local-path`，非生产不做要求。[安装local-path-provisioner](https://git.ketanyun.cn/charts/docs/-/tree/master/%E5%9F%BA%E7%A1%80%E7%8E%AF%E5%A2%83%E5%AE%89%E8%A3%85/k8s%E9%9B%86%E7%BE%A4%E7%BB%84%E4%BB%B6/local-path-provisioner)
- 评估部署方式，后面1.2.3. 三选一

#### 1. helm部署mariadb(正式环境，主从)

- 正式环境部署，要求mariadb单独运行在固定的节点上，并且使用`local-path`。以下示例中，节点`mariadb-primary`和`mariadb-secondary`分别运行主库和从库，具体操作时可以修改为正确的节点名称。

- 修改[values.yaml](./values.yaml)中`primary.configuration`和`secondary.configuration`的`innodb_buffer_pool_size`，设置为服务器内存的50%

```bash
#auth.rootPassword 数据库root密码
#architecture replication表示主从
#global.storageClass 指定集群存储类，正式环境不允许使用nfs
#primary.persistence.size 数据卷大小
#-n ketanyun  安装在哪个命名空间

# 将运行数据库的节点标记污点，阻止其他pod调度
kubectl taint nodes mariadb-primary node-role.kubernetes.io/mariadb=primary:NoSchedule
kubectl taint nodes mariadb-secondary node-role.kubernetes.io/mariadb=secondary:NoSchedule

# 修改以下安装命令中的root密码，确认nodeSelector是否正确
helm upgrade --install mariadb-local mariadb-10.5.1.tgz -f values.yaml  \
-n default --create-namespace \
--version=10.5.1 \
--set global.storageClass=local-path  \
--set image.tag=10.5.22 \
--set auth.rootPassword='' \
--set architecture=replication \
--set primary.nodeSelector='kubernetes.io/hostname: mariadb-primary' \
--set primary.tolerations[0].key='node-role.kubernetes.io/mariadb' \
--set primary.tolerations[0].operator='Equal' \
--set primary.tolerations[0].value='primary' \
--set primary.tolerations[0].effect='NoSchedule' \
--set primary.persistence.size=20Gi  \
--set primary.extraEnvVars[0].name='TZ' \
--set primary.extraEnvVars[0].value='Asia/Shanghai' \
--set primary.priorityClassName='system-cluster-critical' \
--set secondary.nodeSelector='kubernetes.io/hostname: mariadb-secondary' \
--set secondary.tolerations[0].key='node-role.kubernetes.io/mariadb' \
--set secondary.tolerations[0].operator='Equal' \
--set secondary.tolerations[0].value='secondary' \
--set secondary.tolerations[0].effect='NoSchedule' \
--set secondary.persistence.size=20Gi  \
--set secondary.extraEnvVars[0].name='TZ' \
--set secondary.extraEnvVars[0].value='Asia/Shanghai' \
--set secondary.priorityClassName='system-cluster-critical'
```

#### 2. helm部署mariadb(正式环境，单机)

- 正式环境部署，要求mariadb单独运行在固定的节点上，并且使用`local-path`。

- 修改[values.yaml](./values.yaml)中`primary.configuration`的`innodb_buffer_pool_size`，设置为服务器内存的80%

```bash
#auth.rootPassword 数据库root密码
#architecture replication表示主从
#global.storageClass 指定集群存储类，正式环境不允许使用nfs
#primary.persistence.size 数据卷大小
#-n ketanyun  安装在哪个命名空间

# 将运行数据库的节点标记污点，阻止其他pod调度
kubectl taint nodes mariadb node-role.kubernetes.io/mariadb=primary:NoSchedule

# 修改以下安装命令中的root密码，确认nodeSelector是否正确
helm upgrade --install mariadb mariadb-10.5.1.tgz -f values.yaml  \
-n default --create-namespace \
--version=10.5.1 \
--set global.storageClass=local-path  \
--set image.tag=10.5.22 \
--set auth.rootPassword='' \
--set architecture=standalone \
--set primary.nodeSelector='kubernetes.io/hostname: mariadb' \
--set primary.tolerations[0].key='node-role.kubernetes.io/mariadb' \
--set primary.tolerations[0].operator='Equal' \
--set primary.tolerations[0].value='primary' \
--set primary.tolerations[0].effect='NoSchedule' \
--set primary.persistence.size=20Gi  \
--set primary.extraEnvVars[0].name='TZ' \
--set primary.extraEnvVars[0].value='Asia/Shanghai' \
--set primary.priorityClassName='system-cluster-critical'
```

#### 3. helm部署mariadb(使用了nfs，仅允许测试环境使用)

- 修改[values.yaml](./values.yaml)中`primary.configuration`的`innodb_buffer_pool_size`，设置为服务器内存的80%

- 说明: 测试环境安装mariadb,一般来说不需要单独指定到一个节点上(或者可能整个环境就一个节点),此时不需要taint节点,直接安装,同时应该配置resources,避免数据库资源使用过多

```bash
#auth.rootPassword 数据库root密码
#architecture standalone表示单节点，不做主从
#global.storageClass 指定集群存储类
#primary.persistence.size 数据卷大小
#-n ketanyun  安装在哪个命名空间

# 修改以下安装命令中的root密码，确认nodeSelector是否正确
helm upgrade --install mariadb mariadb-10.5.1.tgz -f values.yaml  \
-n default --create-namespace \
--version=10.5.1 \
--set image.tag=10.5.22 \
--set auth.rootPassword='' \
--set architecture=standalone \
--set global.storageClass=nfs-client  \
--set primary.persistence.size=20Gi  \
--set primary.nodeSelector='kubernetes.io/hostname: k8s-node1' \
--set primary.resources.limits.cpu='1'  \
--set primary.resources.limits.memory='4Gi'  \
--set primary.extraEnvVars[0].name='TZ' \
--set primary.extraEnvVars[0].value='Asia/Shanghai' 
```

#### 4. 部署后检查

- 部署完成后，检查mariadb对应的pv，是否正确对应了节点，以及存储路径是否正确

```shell
ubuntu@k8s-node1:~$ kubectl get pvc -n saas | grep mariadb
data-mariadb-0                                  Bound    pvc-fcf2e3a1-f2c2-48d3-bcae-ed5b7a8d579d   20Gi       RWO            local-path     8d

ubuntu@k8s-node1:~$ kubectl describe pv pvc-fcf2e3a1-f2c2-48d3-bcae-ed5b7a8d579d
Name:              pvc-fcf2e3a1-f2c2-48d3-bcae-ed5b7a8d579d
Labels:            <none>
Annotations:       pv.kubernetes.io/provisioned-by: rancher.io/local-path
Finalizers:        [kubernetes.io/pv-protection]
StorageClass:      local-path
Status:            Bound
Claim:             saas/data-mariadb-0
Reclaim Policy:    Retain
Access Modes:      RWO
VolumeMode:        Filesystem
Capacity:          20Gi
Node Affinity:     
  Required Terms:  
    Term 0:        kubernetes.io/hostname in [k8s-node1]   # 确认节点是否正确
Message:           
Source:
    Type:          HostPath (bare host directory volume)
    Path:          /data/local-path-provisioner/pvc-fcf2e3a1-f2c2-48d3-bcae-ed5b7a8d579d_saas_data-mariadb-0   # 确认存储路径是否正确
    HostPathType:  DirectoryOrCreate
Events:            <none>
```

### 二、虚拟化部署mariadb（仅做记录，正式部署要求使用helm在集群中）

> 注意：数据库需要和北京时间一致，故安装前必须设置服务器时区`timedatectl set-timezone Asia/Shanghai`，并配置时间同步服务

- 安装

[访问链接](https://mariadb.org/download/?t=repo-config&d=20.04+%22focal%22&v=10.5&r_m=aliyun)获取安装源，建议版本10.5

```shell
# ubuntu20.04软件源
sudo apt-get install apt-transport-https curl
sudo curl -o /etc/apt/trusted.gpg.d/mariadb_release_signing_key.asc 'https://mariadb.org/mariadb_release_signing_key.asc'
sudo sh -c "echo 'deb https://mirrors.aliyun.com/mariadb/repo/10.5/ubuntu focal main' >>/etc/apt/sources.list"

# 安装
sudo apt-get update
sudo apt-get install mariadb-server
```

- 配置

参考[mysql参数部署规范](https://git.ketanyun.cn/operation/docs/-/wikis/mysql%E5%8F%82%E6%95%B0%E9%83%A8%E7%BD%B2%E8%A7%84%E8%8C%83)配置参数

## 定期备份

参考[backup/README.md](backup/README.md)
