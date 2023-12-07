# 部署

https://docs.pingcap.com/zh/tidb-in-kubernetes/stable/prerequisites


## 1. 配置storageclass

- `local-path-provisioner`默认配置时，需要保证所有节点的存储供应目录一致，即所有节点的数据盘都挂载到同名的目录。


- 部署[local-path-provisioner](https://github.com/rancher/local-path-provisioner)，提供本地存储。

[local-path-storage.yaml](manifests/local-path-storage.yaml)

- 注意修改configmap中的存储路径

```yaml
kind: ConfigMap
apiVersion: v1
metadata:
  name: local-path-config
  namespace: local-path-storage
data:
  config.json: |-
    {
            "nodePathMap":[
            {
                    "node":"DEFAULT_PATH_FOR_NON_LISTED_NODES",
                    "paths":["/opt/local-path-provisioner"]
            }
            ]
    }
```

- 修改reclaimPolicy

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-path
provisioner: rancher.io/local-path
volumeBindingMode: WaitForFirstConsumer
reclaimPolicy: Retain
```


## 2. 安装operator

- 安装helm命令行

- 安装crd

[crd.yaml](manifests/crd.yaml)

```shell
kubectl create -f https://raw.githubusercontent.com/pingcap/tidb-operator/v1.4.5/manifests/crd.yaml
```

- 安装operator

```shell
helm repo add pingcap https://charts.pingcap.org/

helm install tidb-operator pingcap/tidb-operator --namespace=tidb-admin --create-namespace \
--set scheduler.create='false' \

# 以下调度参数可选，具体根据是否要让tidb-operator和tidb运行在一起
--set controllerManager.nodeSelector.'app\.kubernetes\.io/component'=tidb \
--set controllerManager.tolerations[0].effect=NoSchedule \
--set-string controllerManager.tolerations[0].key="node-role.kubernetes.io/tidb" \
--set controllerManager.tolerations[0].operator="Exists" 


kubectl get po -n tidb-admin -l app.kubernetes.io/name=tidb-operator
```


## 3. 规划tidb使用的woker节点

可选单机模式或者高可用，单机模式需要1个节点。高可用模式需要至少3个节点。


```shell
# tidb节点标记taint，阻止tidb之外的程序调度
kubectl taint nodes k8s-node1 node-role.kubernetes.io/tidb=:NoSchedule
kubectl taint nodes k8s-node2 node-role.kubernetes.io/tidb=:NoSchedule
kubectl taint nodes k8s-node3 node-role.kubernetes.io/tidb=:NoSchedule

# tidb节点打标签，供调度
kubectl label node k8s-node1 app.kubernetes.io/component=tidb
kubectl label node k8s-node2 app.kubernetes.io/component=tidb
kubectl label node k8s-node3 app.kubernetes.io/component=tidb
```

## 4. 修改tidb集群配置(修改tidb-cluster.yaml)

> pd是tidb元数据存储组件，内置etcd
> tidb是计算组件，本身不需要数据持久化
> tikv是存储组件，需要数据持久化且对磁盘性能有要求，所以必须使用k8s本地存储。
> pump是binlog相关组件，必须安装pump，才能开启binlog

[tidb-cluster.yaml](manifests/tidb-cluster.yaml)


#### 修改各组件副本数量

- 单机模式修改所有replicas=1

- 高可用模式：
  - pd = 3
  - tikv = 上一步中规划的节点数量
  - tidb = 上一步中规划的节点数量

#### 修改storageclass

在文件中搜索所有storageClassName修改


#### 其他参数待补充

## 5. 部署tidb集群

```shell
kubectl create namespace tidb

kubectl apply -f tidb-cluster.yaml -n tidb
```

- 待所有组件启动完成之后，再进行下一步初始化

```shell
root@k8s-master1:~/books/k8s-applications/tidb# kubectl get po -n tidb 
NAME                                           READY   STATUS      RESTARTS   AGE
advanced-tidb-discovery-68f65f6fb-sls7t        1/1     Running     3          7d3h
advanced-tidb-pd-0                             1/1     Running     3          7d3h
advanced-tidb-pd-1                             1/1     Running     2          5d21h
advanced-tidb-pd-2                             1/1     Running     2          5d21h
advanced-tidb-pump-0                           1/1     Running     3          6d2h
advanced-tidb-pump-1                           1/1     Running     3          5d21h
advanced-tidb-pump-2                           1/1     Running     3          5d21h
advanced-tidb-ticdc-0                          1/1     Running     0          42m
advanced-tidb-ticdc-1                          1/1     Running     0          42m
advanced-tidb-ticdc-2                          1/1     Running     0          42m
advanced-tidb-tidb-0                           2/2     Running     5          6d2h
advanced-tidb-tidb-1                           2/2     Running     5          5d21h
advanced-tidb-tidb-2                           2/2     Running     0          29m
advanced-tidb-tikv-0                           1/1     Running     4          7d3h
advanced-tidb-tikv-1                           1/1     Running     1          44h
advanced-tidb-tikv-2                           1/1     Running     0          22m
```



## 6. 初始化

```shell
# 创建root用户密码secret
kubectl create secret generic tidb-secret --from-literal=root="123qqq...A" --namespace=tidb
```

- 修改tidb-init.yaml

[tidb-init.yaml](manifests/tidb-init.yaml)

```yaml
spec:
  # 上一步安装的tidb的信息
  cluster:
    namespace: tidb
    name: advanced-tidb
  # 配置的sql会被执行，可以执行例如建库建用户sql
  initSql: |
    create database app;
  # 这个secret中的用户会被创建用户名是secretKey，密码为Value
  passwordSecret: tidb-secret
```

- 执行初始化

```shell
# 产生一个job，需等待该job执行完成即初始化结束
kubectl -n tidb create -f ./manifest/tidb-init.yaml

root@k8s-master1:~/books/k8s-applications/tidb# kubectl get po -n tidb -l app.kubernetes.io/component=initializer
NAME                                   READY   STATUS      RESTARTS   AGE
advanced-tidb-tidb-initializer-c7jtq   0/1     Completed   0          7d3h
```

## 7. tidb dashboard

- dashboarad集成在pd中，可修改pd的svc为NodePort，通过NodePort端口访问

```shell
kubectl get svc -n tidb -l app.kubernetes.io/component=pd,app.kubernetes.io/used-by=end-user
```
