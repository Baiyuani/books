
## [charts](https://github.com/neuvector/neuvector-helm/tree/master/charts/core)

```shell
helm repo add neuvector https://neuvector.github.io/neuvector-helm/

helm search repo neuvector/core
NAME            CHART VERSION   APP VERSION     DESCRIPTION                             
neuvector/core  2.4.2           5.1.1           Helm chart for NeuVector's core services
```

```shell
helm upgrade --install neuvector -n neuvector neuvector/core --create-namespace \
--set controller.replicas=1 \
--set cve.scanner.replicas=1 \
--set manager.ingress.enabled=true \
--set manager.ingress.host='manage-neuvector.local.domain' 


# 数据持久化
--set controller.pvc.enabled=true \
--set controller.pvc.storageClass='standard' \
--set controller.pvc.capacity='1Gi' \


# 自定义NeuVector configuration
--set controller.configmap.enabled=true \
--set controller.configmap.data={} \


# 0为禁用，建议设置2
--set controller.disruptionbudget=2 \


# 控制器 REST API 服务类型
--set controller.apisvc.type='ClusterIP' \
--set controller.ingress.enabled=true \
--set controller.ingress.host='neuvector.local.domain' \
# 多集群托管集群服务类型
--set controller.federation.managedsvc.type='ClusterIP' \
--set controller.federation.managedsvc.ingress.enabled=true \
--set controller.federation.managedsvc.ingress.host='manage-federation.local.domain' \
# 多集群主集群服务类型
--set controller.federation.mastersvc.type='ClusterIP' \
--set controller.federation.mastersvc.ingress.enabled=true \
--set controller.federation.mastersvc.ingress.host='master-federation.local.domain' \
```
