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
