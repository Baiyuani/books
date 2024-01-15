---
tags: 
  - minio
  - gitlab
---

## 安装minio

```shell
helm repo add minio https://charts.min.io/

# rootUser 管理员用户
# users 创建普通用户，secretKey为用户的密码
# svcaccts 创建service account给gitlab-runner使用。注意accessKey和secretKey需要满足复杂度要求
helm install runner-cache-minio minio/minio \
--namespace gitlab --create-namespace \
--version 5.0.15 \
--set mode='standalone' \
--set persistence.storageClass='nfs-client' \
--set persistence.size='500Gi' \
--set rootUser='minio' \
--set rootPassword='' \
--set buckets[0].name=runner,buckets[0].policy=none,buckets[0].purge=false \
--set users[0].accessKey=runner,users[0].secretKey=fgGft567gs,users[0].policy=readwrite \
--set svcaccts[0].accessKey=GbbNXEe1c2s1hj9srvWp,svcaccts[0].secretKey=pEhzoHydH3zEYPVO7NEsXsHznHy4lfJvkuNqJTrn,svcaccts[0].user=runner \
--set consoleIngress.enabled=true \
--set consoleIngress.hosts[0]='minio.xxx.xxx' \
--set consoleIngress.ingressClassName=nginx \
--set resources.requests.memory='128Mi' \
--set resources.requests.cpu='100m'
```

附：安装后建议为bucket配置lifecycle，防止数据持续增长最终写满磁盘。

访问minio-console -> Buckets -> runner -> Lifecycle -> Add Lifecycle Rule -> After 填写数据保留多少天 -> save


## mc ilm 设置对象生命周期

https://min.io/docs/minio/linux/reference/minio-mc.html

```shell
## 安装mc命令行

wget https://dl.min.io/client/mc/release/linux-amd64/mc
chmod +x mc
```

```shell
## 添加minio配置
./mc config host add ketanyun http://10.244.163.88:9000

## 列出所有host
./mc config host list

## 查看一个host中的所有buckets
./mc ls ketanyun

## 添加ilm策略，数据保留180天
./mc ilm add --expiry-days 180 ketanyun/runner

## 查看指定bucket的ilm策略（生命周期策略）
./mc ilm ls ketanyun/runner

┌───────────────────────────────────────────────────────────────────────────────────────┐
│ Expiration for latest version (Expiration)                                            │
├──────────────────────┬─────────┬────────┬──────┬────────────────┬─────────────────────┤
│ ID                   │ STATUS  │ PREFIX │ TAGS │ DAYS TO EXPIRE │ EXPIRE DELETEMARKER │
├──────────────────────┼─────────┼────────┼──────┼────────────────┼─────────────────────┤
│ ci9t02ik5q2hvnbimsc0 │ Enabled │ -      │ -    │            180 │ false               │
└──────────────────────┴─────────┴────────┴──────┴────────────────┴─────────────────────┘

## 移除指定的ilm策略
./mc ilm rm --id "ci9t02ik5q2hvnbimsc0" ketanyun/runner
```
