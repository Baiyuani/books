# metrics-server

## 安装监控数据聚合器

[components.yaml](components.yaml)

[high-availability.yaml](high-availability.yaml)

[high-availability-1.21+.yaml](high-availability-1.21%2B.yaml)


```bash
wget https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.6.4/components.yaml


vim components.yaml
...
spec:
...
  template:
    metadata:
      labels:
        k8s-app: metrics-server
    spec:
      containers:
      - args:
        - --cert-dir=/tmp
        - --secure-port=4443
        - --kubelet-preferred-address-types=InternalIP   # 删掉 ExternalIP,Hostname这两个
        - --kubelet-use-node-status-port
        - --metric-resolution=15s
        - --kubelet-insecure-tls       #   加上该启动参数
        image: registry.cn-hangzhou.aliyuncs.com/google_containers/metrics-server:v0.6.4    # 镜像地址根据情况修改     



kubectl apply -f components.yaml
kubectl top 
```


## [bitnami](https://github.com/bitnami/charts/tree/master/bitnami/metrics-server)

```shell
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install metrics-server bitnami/metrics-server -n kube-system
```



## [官方chart](https://artifacthub.io/packages/helm/metrics-server/metrics-server)

https://github.com/kubernetes-sigs/metrics-server/releases/tag/metrics-server-helm-chart-3.8.2

```shell
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm upgrade --install metrics-server metrics-server/metrics-server -n kube-system
```
