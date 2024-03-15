---
tags:
  - pgsql
  - postgre
---

# pgsql

[bitnami](https://github.com/bitnami/charts/tree/main/bitnami/postgresql)


## 部署[支持1.19集群的版本](https://artifacthub.io/packages/helm/bitnami/postgresql/12.12.10)


```shell
helm install pgsql oci://registry-1.docker.io/bitnamicharts/postgresql --version 12.12.10 \
--set global.storageClass=nfs-client \
--set global.postgresql.auth.postgresPassword='' \
--set architecture=standalone \
--set primary.resources.limits.memory=2048Mi \
--set primary.resources.limits.cpu=1000m \
--set primary.resources.requests.memory=256Mi \
--set primary.resources.requests.cpu=250m \
-n saas
```

