## k8s裸机LB服务


    可选L2模式和BGP模式，L2最简单，兼容性好，可以在几乎所有网络上工作，但原理是类似keepalived，拥有IP的节点将成为瓶颈并限制性能；
    其次，在节点消失的情况下进行故障转移的时间可能会很慢；
    第三，地址分配空间必须是集群节点网络的一部分。
    BGP相较L2性能更好，需要配置BGP路由器的IP地址和ASN信息来和路由器进行BGP对等连接，这在虚拟网络中可能无法配置（待确认）。


### install
```shell
helm repo add metallb https://metallb.github.io/metallb
helm install metallb metallb/metallb -n metallb-system --create-namespace
```

### [configuration](https://metallb.universe.tf/configuration/)

##### 1. L2

创建地址池：
```yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  addresses:
#  - 192.168.10.0/24
  - 192.168.17.200-192.168.17.210
#  - fc00:f853:0ccd:e799::/124
```

创建L2Advertisement：
```shell
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: example
  namespace: metallb-system
spec:
  ipAddressPools:
  - first-pool
```

##### 2. BGP

创建BGP对等连接
```yaml
apiVersion: metallb.io/v1beta2
kind: BGPPeer
metadata:
  name: sample
  namespace: metallb-system
spec:
  myASN: 64500
  peerASN: 64501
  peerAddress: 192.168.17.2
```

检查BGP对等连接状态
```shell
# 如果连接失败，则在metallb-speaker日志中看到类似以下内容（179为BGP路由器对等连接端口）
{"caller":"native.go:90","error":"dial \"192.168.17.2:179\": getsockopt: connection refused","level":"error","localASN":64500,"msg":"failed to connect to peer","op":"connect","peer":"192.168.17.2:179","peerASN":64501,"ts":"2023-03-04T09:45:56Z"}
```


创建地址池：
```yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  addresses:
#  - 192.168.10.0/24
  - 192.168.17.200-192.168.17.210
#  - fc00:f853:0ccd:e799::/124
```

创建BGPAdvertisement：
```yaml
apiVersion: metallb.io/v1beta1
kind: BGPAdvertisement
metadata:
  name: example
  namespace: metallb-system
spec:
  ipAddressPools:
  - first-pool
```





### 实际应用

- 搭配ingress-nginx

```yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: ippool-ingress-nginx
  namespace: metallb-system
spec:
  addresses:
    - 192.168.17.199/32
  avoidBuggyIPs: true
  serviceAllocation:
    priority: 50
    namespaces:
      - ingress-nginx
#    namespaceSelectors:
#      - matchLabels:
#          foo: bar
    serviceSelectors:
      - matchExpressions:
          - key: app.kubernetes.io/instance 
            operator: In
            values: 
              - nginx-ingress-controller
  
--- 
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: l2-ingress-nginx
  namespace: metallb-system
spec:
  ipAddressPools:
  - ippool-ingress-nginx
```

```shell
# 创建上面的metal配置
kubectl create -f -

# 安装ingress-nginx
helm upgrade --install nginx-ingress-controller bitnami/nginx-ingress-controller --version=9.3.24 -f values.yaml \
-n ingress-nginx --create-namespace \
--set ingressClassResource.default=true \
--set defaultBackend.enabled=false

# EXTERNAL-IP可看到分配的IP
root@k8s-master1:~/operations/k8s/kube-system/ingress-nginx-controller/bitnami-nginx-ingress-controller-9.3.24# kubectl get svc -A
NAMESPACE        NAME                                       TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)                         AGE
default          kubernetes                                 ClusterIP      10.96.0.1       <none>           443/TCP                         83m
ingress-nginx    nginx-ingress-controller                   LoadBalancer   10.96.18.243    192.168.17.199   80:30015/TCP,443:30893/TCP      4s

# 测试访问
```