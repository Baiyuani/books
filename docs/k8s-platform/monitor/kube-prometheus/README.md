# k8s环境prometheus监控实施方案
> 更新日期：20220925


## 一、安装
> [chart仓库地址](https://github.com/bitnami/charts/tree/b0e5cc70bf1175e40034fcc49eafb733b5916e4c/bitnami/kube-prometheus)

### 1.配置告警接收人信息

[alertmanager.yaml](alertmanager-configs%2Falertmanager.yaml)

```shell
#::TODO
```

### 2.配置告警信息模板

[cluster.tmpl](alertmanager-configs%2Fcluster.tmpl)

[node.tmpl](alertmanager-configs%2Fnode.tmpl)

[web.tmpl](alertmanager-configs%2Fweb.tmpl)

```shell
#::TODO
```

### 3.配置站点和接口监控地址

[additionalScrapeConfigs.yaml](manifests%2FadditionalScrapeConfigs.yaml)

```shell
#::TODO
```

### 4.（可选）修改prometheus rules

[rules](rules)(需到git仓库查看)

```shell
#::TODO
```

### 5.（可选）部署企微群机器人adapter

[webhook-adapter.yaml](manifests%2Fwebhook-adapter.yaml)

```shell
#::TODO
```

### 6.install
```bash
# prometheus helm repo
kubectl create ns prometheus
helm repo add bitnami https://charts.bitnami.com/bitnami

# （可选）企微群机器人adapter
kubectl -n prometheus apply -f ./manifests/webhook-adapter.yaml

# 创建扩展数据采集配置，以使用blackbox监控服务可用性，有修改时再次执行即可，不需要重启服务
kubectl -n prometheus create secret generic additional-scrape-configs --from-file=./manifests/additionalScrapeConfigs.yaml --dry-run=client -o yaml | kubectl apply -f -

# 配置alertmanager（告警消息模板，消息渠道配置），有修改时再次执行即可，不需要重启服务
kubectl -n prometheus create secret generic alertmanager-kube-prometheus-alertmanager --from-file=./alertmanager-configs --dry-run=client -o yaml | kubectl apply -f -

# @param prometheus.persistence.size 配置Prometheus数据卷大小
# @param prometheus.retention 监控数据保留天数
# @param prometheus.retentionSize 监控数据保留大小
# @param prometheus.ingress.hostname prometheus域名
# @param alertmanager.ingress.hostname alertmanager域名
# @param alertmanager.retention 告警数据保留时间
# prometheus.replicaCount alertmanager.replicaCount blackboxExporter.replicaCount 控制副本数量，无需高可用可去掉这些参数
# 其余resources配置根据实际情况修改
# 注意，release name(kube-prometheus)不可变
helm upgrade --install kube-prometheus bitnami/kube-prometheus -n prometheus \
--version=8.1.5  \
--set global.storageClass='nfs-client' \
--set prometheus.additionalScrapeConfigs.enabled=true \
--set prometheus.additionalScrapeConfigs.external.name='additional-scrape-configs'  \
--set prometheus.additionalScrapeConfigs.external.key='additionalScrapeConfigs.yaml' \
--set prometheus.persistence.enabled=true \
--set prometheus.persistence.size=30Gi  \
--set prometheus.retention=15d \
--set prometheus.retentionSize=""  \
--set prometheus.ingress.enabled=true  \
--set prometheus.ingress.hostname=prometheus.baiyuani.top \
--set alertmanager.ingress.enabled=true \
--set alertmanager.ingress.hostname=alertmanager.baiyuani.top \
--set alertmanager.persistence.enabled="true" \
--set alertmanager.persistence.size="8Gi" \
--set alertmanager.retention=120h \
--set alertmanager.externalConfig=true \
--set prometheus.replicaCount=3 \
--set alertmanager.replicaCount=3 \
--set blackboxExporter.replicaCount=2 \
--set operator.resources.limits.cpu=500m  \
--set operator.resources.limits.memory=512Mi  \
--set operator.resources.requests.cpu=100m  \
--set operator.resources.requests.memory=128Mi  \
--set prometheus.resources.limits.cpu=500m  \
--set prometheus.resources.limits.memory=2Gi  \
--set prometheus.resources.requests.cpu=100m  \
--set prometheus.resources.requests.memory=128Mi  \
--set alertmanager.resources.limits.cpu=500m  \
--set alertmanager.resources.limits.memory=1Gi  \
--set alertmanager.resources.requests.cpu=100m  \
--set alertmanager.resources.requests.memory=128Mi  

# 创建Prometheus rules
kubectl -n prometheus apply -f ./rules/

```

### 7. 开启etcd接口
> 注意：该配置会导致etcd重启，正式环境建议经过评估再操作！ 

```shell
# 登录所有master
vim /etc/kubernetes/manifests/etcd.yaml
# 修改- --listen-metrics-urls=http://127.0.0.1:2381为
    - --listen-metrics-urls=http://0.0.0.0:2381
```
- 创建serviceMonitor
```shell
kubectl apply -f manifests/serviceMonitor-etcd.yaml
```

### 8. 开启ingress-nginx接口
```shell
#根据版本不同可能不一致
```
- 创建serviceMonitor(根据环境修改)
```shell
kubectl apply -f manifests/serviceMonitor-ingress-nginx.yaml
```


## 二、指标

### 监控指标

| Name             | Description                          |
|------------------|--------------------------------------|
| `监控数据保留时间 ` | 30天                                  | 
| `pod状态` | 启停，异常，升级等持续5分钟异常时告警。POD实际运行内存和配置内存的比例 |
| `服务器告警` | cpu使用率>60%,内存使用率>80%,磁盘使用率>80%       | 
|`告警推送间隔`| 5分钟                                  |
|`在没有报警的情况下声明为已解决的时间`| 5分钟                                  |
|`是否发送异常恢复通知`| 是                                    |
|`服务存活情况`| 持续5min服务状态码>399                      |


### 告警消息示例
```
==========异常告警==========
告警类型: 服务器_内存使用情况异常
告警级别: warning
告警详情: 内存使用率超过80%
  Node 192.168.1.28:9100
故障时间: 2022-05-17 14:44:19
实例信息: 192.168.1.28:9100
============END============
```