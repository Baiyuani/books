# Loki

[官方](https://grafana.com/oss/loki/)

[grafana所有charts](https://github.com/grafana/helm-charts/tree/main/charts)


[promtail文档](https://grafana.com/docs/loki/latest/clients/promtail/installation/)
[promtail charts](https://github.com/grafana/helm-charts/tree/main/charts/promtail)


## 配置charts仓库

```shell
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```

## 部署loki

### 一、[单节点部署](https://github.com/grafana/loki/tree/main/production/helm/loki)(优先使用，资源使用少)
```shell
# loki 5.41.4
helm upgrade --install loki grafana/loki -n loki \
--create-namespace \
--version 5.41.4 \
--set loki.auth_enabled=false \
--set monitoring.selfMonitoring.enabled=false \
--set monitoring.selfMonitoring.grafanaAgent.installOperator=false \
--set test.enabled=false \
--set monitoring.lokiCanary.enabled=false \
--set singleBinary.replicas=1 \
--set singleBinary.persistence.size='20Gi' \
--set singleBinary.persistence.storageClass='local-path' \
--set singleBinary.nodeSelector.'kubernetes\.io/hostname'='k8s-node2' \
--set loki.commonConfig.replication_factor=1 \
--set minio.enabled=true \
--set minio.mode='standalone' \
--set minio.persistence.storageClass='nfs-client' \
--set minio.persistence.size='300Gi' \
--set minio.rootUser='' \
--set minio.rootPassword='' \
--set minio.consoleIngress.enabled=true \
--set minio.consoleIngress.hosts[0]='loki-minio.xxx.xxx' \
--set minio.consoleIngress.ingressClassName=nginx \
--set podDisruptionBudget=''
# 如果--set singleBinary.replicas=1时
#--set loki.commonConfig.replication_factor=1 \

# singleBinary.persistence.storageClass 不能使用nfs，有性能要求
```


### 二、[loki可扩展方式部署](https://github.com/grafana/loki/tree/main/production/helm/loki)

#### 方式一：安装loki，不启用operator，关闭自监控，使用promtail收集整个k8s的日志
```shell
# loki 5.15.0
helm upgrade --install loki grafana/loki -n loki \
--set minio.enabled=true \
--set loki.auth_enabled=false \
--set monitoring.selfMonitoring.enabled=false \
--set monitoring.selfMonitoring.grafanaAgent.installOperator=false \
--set test.enabled=false \
--set minio.persistence.storageClass='nfs-client' \
--set minio.persistence.size='200Gi' \
--set minio.rootUser='' \
--set minio.rootPassword='' \
--set minio.consoleIngress.enabled=true \
--set minio.consoleIngress.hosts[0]='loki-minio.xxx.xxx' \
--set minio.consoleIngress.ingressClassName=nginx \
```



#### 方式二：安装loki，使用operator，需要编写cr，[参考PodLogs.yaml](PodLogs.yaml)，通过cr控制收集k8s里哪些pod的日志

[PodLogs.yaml](PodLogs.yaml)

```shell
# loki 4.6.1
helm upgrade --install loki grafana/loki -n loki \
--set minio.enabled=true \
--set loki.auth_enabled=false
```



### loki可选参数

```shell
# loki副本数配置，需要根据pod数量调整，默认3，即需要3个pod，且至少有2个pod存活时才能正常工作。如果设置为1，则可以调整pod数量为1
--set read.replicas=1 \
--set write.replicas=1 \
--set backend.replicas=1 \
--set loki.commonConfig.replication_factor=1 \


# 各组件pvc配置，minio为日志存储后端，read和write的pvc只用于临时存储，但为了避免重启导致数据部分丢失，所以还是需要挂载pvc
--set minio.persistence.storageClass='nfs-client' \
--set minio.persistence.size='200Gi' \
--set write.persistence.storageClass='nfs-client' \
--set write.persistence.size='20Gi' \
--set read.persistence.storageClass='nfs-client' \
--set read.persistence.size='20Gi' \
--set backend.persistence.storageClass='nfs-client' \
--set backend.persistence.size='20Gi' \


# serviceMonitor默认开启，没有promtheus时可关闭
# 老版本中为--set serviceMonitor.enabled=false \
--set monitoring.serviceMonitor.enabled=false
--set serviceMonitor.enabled=false 

# minio认证配置
--set minio.rootUser='' \
--set minio.rootPassword='' \


# minio bucket策略配置 policy
minio:
  buckets:
    - name: chunks
      policy: none
      purge: false
    - name: ruler
      policy: none
      purge: false
    - name: admin
      policy: none
      purge: false


# 启用table manager来管理存储表的生命周期，https://grafana.com/docs/loki/latest/operations/storage/table-manager/
# 后端存储为对象存储时无效，需要通过设置存储桶的生命周期管理。
--set tableManager.enabled=true \
# 如果安装4.10.0版本，不支持以下2个参数，需要安装以后手工修改`kubectl edit cm -n loki loki`
--set tableManager.retention_deletes_enabled=true \
--set tableManager.retention_period=744h \


# 关闭loki-canary（loki系统分析组件，配置prometheus+grafana使用）
--set monitoring.lokiCanary.enabled=false \
```


## 部署promtail

```shell
# promtail 6.15.3
# 注意：默认配置docker容器日志路径为/var/lib/docker/containers，可根据实际环境情况将正确的docker路径添加配置进去即可
helm upgrade --install promtail grafana/promtail -n loki \
--version 6.15.3 \
--set configmap.enabled=true \
--set serviceMonitor.enabled=false 


# 
--set tolerations[0].key='node-role.kubernetes.io/master' \
--set tolerations[0].operator='Exists' \
--set tolerations[0].effect='NoSchedule' \
--set tolerations[1].key='node-role.kubernetes.io/control-plane' \
--set tolerations[1].operator='Exists' \
--set tolerations[1].effect='NoSchedule' \


# docker数据目录不是默认时，添加以下配置以使程序能读取到日志
--set extraVolumes[0].name='containers2' \
--set extraVolumes[0].hostPath.path='/data/docker/containers' \
--set extraVolumeMounts[0].name='containers2' \
--set extraVolumeMounts[0].mountPath='/data/docker/containers' \
--set extraVolumeMounts[0].readOnly=true \
```


## sidecar示例

[infoplus-sts.yaml](infoplus-sts.yaml)

[promtail-sidecar.yaml](promtail-sidecar.yaml)


## grafana查询

```logql
# 解析json格式日志，只输出log内容
{} | json | line_format `{{.log}}`
```
