# redis

## [使用helm部署redis](https://github.com/bitnami/charts/tree/81551c13f37839b70251bf859b3427bcedfd0022/bitnami/redis)


```shell
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update


# 单节点，没密码
helm install redis bitnami/redis -n dev \
--version=16.9.10 \
--set global.storageClass='nfs-client' \
--set master.persistence.size='30Gi' \
--set architecture='standalone' \
--set auth.enabled='false' 


# 集群模式，有密码
helm install redis-cluster bitnami/redis -n dev \
--version=16.9.10 \
--set global.storageClass='nfs-client' \
--set master.persistence.size='30Gi' \
--set replica.persistence.size='30Gi' \
--set global.redis.password='qqq...AAA!!!' 
```