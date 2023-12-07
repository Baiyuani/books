# mariadb

## 部署mariadb

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


- 自动备份



## helm部署mariadb(测试环境)

> https://github.com/bitnami/charts/tree/db82355a553763690aad85629120e97976ca396b/bitnami/mariadb

[values.yaml](values.yaml)

```bash
#auth.rootPassword 数据库root密码
#architecture standalone表示单节点，不做主从
#global.storageClass 指定集群存储类
#primary.persistence.size 数据卷大小
#-n ketanyun  安装在哪个命名空间
helm upgrade --install mariadb-local mariadb-10.5.1.tgz -f values.yaml  \
-n default --create-namespace \
--version=10.5.1 \
--set image.tag=10.5.22 \
--set auth.rootPassword='1qaz@WSX' \
--set architecture=standalone \
--set global.storageClass=nfs-client  \
--set primary.persistence.size=20Gi  \
--set primary.nodeSelector='kubernetes.io/hostname: k8s-master1' \
--set primary.resources.limits.cpu='1'  \
--set primary.resources.limits.memory='1Gi'  \
--set primary.extraEnvVars[0].name='TZ' \
--set primary.extraEnvVars[0].value='Asia/Shanghai' 
```


## helm部署mariadb(正式环境)
> https://github.com/bitnami/charts/tree/db82355a553763690aad85629120e97976ca396b/bitnami/mariadb

- 正式环境部署，要求mariadb示例单独运行在固定的节点上，并且使用高性能存储。

```bash
#auth.rootPassword 数据库root密码
#architecture replication表示主从
#global.storageClass 指定集群存储类，正式环境不允许使用nfs
#primary.persistence.size 数据卷大小
#-n ketanyun  安装在哪个命名空间

kubectl taint nodes mariadb-primary node-role.kubernetes.io/mariadb=primary:NoSchedule
kubectl taint nodes mariadb-secondary node-role.kubernetes.io/mariadb=secondary:NoSchedule

# tidb节点打标签，供调度
kubectl label node k8s-node1 app.kubernetes.io/component=tidb
kubectl label node k8s-node2 app.kubernetes.io/component=tidb


helm upgrade --install mariadb-local mariadb-10.5.1.tgz -f values.yaml  \
-n default --create-namespace \
--version=10.5.1 \
--set global.storageClass=local-path  \
--set image.tag=10.5.22 \
--set auth.rootPassword='1qaz@WSX' \
--set architecture=replication \
--set primary.nodeSelector='kubernetes.io/hostname: mariadb-primary' \
--set primary.tolerations[0].key='node-role.kubernetes.io/mariadb' \
--set primary.tolerations[0].operator='Equal' \
--set primary.tolerations[0].value='primary' \
--set primary.tolerations[0].effect='NoSchedule' \
--set primary.persistence.size=20Gi  \
--set primary.extraEnvVars[0].name='TZ' \
--set primary.extraEnvVars[0].value='Asia/Shanghai' \
--set secondary.nodeSelector='kubernetes.io/hostname: mariadb-secondary' \
--set secondary.tolerations[0].key='node-role.kubernetes.io/mariadb' \
--set secondary.tolerations[0].operator='Equal' \
--set secondary.tolerations[0].value='secondary' \
--set secondary.tolerations[0].effect='NoSchedule' \
--set secondary.persistence.size=20Gi  \
--set secondary.extraEnvVars[0].name='TZ' \
--set secondary.extraEnvVars[0].value='Asia/Shanghai' 
```
