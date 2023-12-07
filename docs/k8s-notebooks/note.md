# Note

## 镜像仓库凭证

创建imagePullSecret，并**覆盖旧的**

```shell
kubectl create secret docker-registry registry -n ketanyun --docker-server=docker.qtgl.com.cn --docker-username=xx --docker-password=xx --dry-run=client -o yaml | kubectl apply -f -
```


## dashboard登录token生成
dashboard创建用户，生成token
```shell
kubectl create sa dashboard-admin -n kube-system
```
给用户绑定角色
```shell
kubectl create clusterrolebinding dashboard-admin --clusterrole=cluster-admin --serviceaccount=kube-system:dashboard-admin
```
查看用户的token：
```shell
kubectl describe secrets -n kube-system $(kubectl -n kube-system get secret | awk '/dashboard-admin/{print $1}')
```




## [kubectl 使用token的方式连接到集群](https://www.cnblogs.com/AnAng/p/12056963.html)

首先得有一个账户

```shell
kubectl create serviceaccount dashboard-admin -n kube-system #创建一个名叫dashboard-admin 命名空间在kube-system 下的服务账户
kubectl create clusterrolebinding dashboard-admin --clusterrole=cluster-admin --serviceaccount=kube-system:dashboard-admin #dashboard-admin 绑定为集群账户
kubectl describe secrets -n kube-system $(kubectl -n kube-system get secret | awk '/dashboard-admin/{print $1}') #显示出名字为dashboard-admin-*的第一个匹配账户的详细信息
```

这里创建一个用来登录kubernetes的账户 

如果有直接执行第三条命令取出token

```shell
 kubectl config set-credentials tf-admin --token={上文的Token} #配置登录方式 这里我使用的是token登录 通过kubectl describe secrets -n kube-system $(kubectl -n kube-system get secret | awk '/dashboard-admin/{print $1}') 命令可以查看一条
 kubectl config set-cluster tf-cluster --insecure-skip-tls-verify=true --server={集群的连接地址https://xx.xx.xx.xx:xx} #配置连接地址
 kubectl config set-context tf-system --cluster=tf-cluster --user=tf-admin 
 kubectl config use-context tf-system  
```





## k8s集群添加新节点

```shell
# 添加node
#创建新token，24h过期
kubeadm token create --print-join-command

#查看Kubernetes认证的SHA256加密字符串
#openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'

#在新node上执行命令加入集群
kubeadm join 192.168.0.11:6443 --token mkfx10.hjw8sa2xf59bgs24 \
    --discovery-token-ca-cert-hash sha256:7e75028528c15e2d62dc3c8a729b04808f086ed3fbea096539a0ea629f3c2ced
```

```shell
#添加master节点
kubeadm token create --print-join-command

#查看certificate-key
kubeadm init phase upload-certs --upload-certs

kubeadm join 192.168.0.11:6443 --token mkfx10.hjw8sa2xf59bgs24 \
    --discovery-token-ca-cert-hash sha256:7e75028528c15e2d62dc3c8a729b04808f086ed3fbea096539a0ea629f3c2ced \
    --control-plane --certificate-key 8d2709697403b74e35d05a420bd2c19fd8c11914eb45f2ff22937b245bed5b68
```



## Unable to connect to the server: x509: certificate is valid for ingress.local
```shell
kubectl ... --insecure-skip-tls-verify

  or
  
clusters:
- cluster:
    server: https://cluster.mysite.com
    insecure-skip-tls-verify: true
  name: default
- 
```

## 重置节点后的操作

rm -rf /etc/kubernetes/* && rm -rf ~/.kube/* && rm -rf /var/lib/etcd/*



## taint

```shell
# 查看node的taints
kubectl get node k8s-masterc -o yaml
  taints:
  - effect: NoSchedule
    key: node-role.kubernetes.io/master
# 配置调度到这台机器的应用
kubectl edit -n ns deploy rancher
      containers:
        ···
      tolerations:
      - key: node-role.kubernetes.io/master
        operator: "Exists"   
        value: "v1"  #当op=Exists可为空
        effect: NoSchedule  #可以为空，匹配所有

```



## 修改kubelet和etcd的存储目录
https://blog.csdn.net/qq_39826987/article/details/126473129




## linux安装kubectl-convert
```shell
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl-convert"
sudo install -o root -g root -m 0755 kubectl-convert /usr/local/bin/kubectl-convert
```

## 将docker-compose转成k8s的yaml格式配置
```shell
# 下载二进制包
# https://github.com/kubernetes/kompose/releases

# 开始转发yaml配置
./kompose-linux-amd64 -f docker-compose.yml convert
```

## 更换master节点

```shell
## 背景，原master节点故障，已踢出集群，提供新服务器，ip等配置不变，重新加入

- 可使用部署k8s集群脚本，将其他主机在hosts中注释，只留下需要的主机，只运行脚本第一段初始化

ansible-playbook  deploy.yml --tags common


## 在其他master中获取加入集群命令 （需先做下一步再执行加入节点操作）

# 添加node
#创建新token，24h过期
kubeadm token create --print-join-command

#查看Kubernetes认证的SHA256加密字符串
#openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'

#在新node上执行命令加入集群
kubeadm join 192.168.0.11:6443 --token mkfx10.hjw8sa2xf59bgs24 \
    --discovery-token-ca-cert-hash sha256:7e75028528c15e2d62dc3c8a729b04808f086ed3fbea096539a0ea629f3c2ced


#添加master节点
kubeadm token create --print-join-command

#查看certificate-key
kubeadm init phase upload-certs --upload-certs

kubeadm join 172.17.0.1:6443 --token mkfx10.hjw8sa2xf59bgs24 \
    --discovery-token-ca-cert-hash sha256:7e75028528c15e2d62dc3c8a729b04808f086ed3fbea096539a0ea629f3c2ced \
    --control-plane --certificate-key 8d2709697403b74e35d05a420bd2c19fd8c11914eb45f2ff22937b245bed5b68


## 在现有etcd中去除原有节点信息

## 删除cm中信息
kubectl edit configmaps -n kube-system kubeadm-config

ClusterStatus: |
    apiEndpoints:
      node130:
        advertiseAddress: 192.168.3.130
        bindPort: 6443
#      node131:
#        advertiseAddress: 192.168.3.131
#        bindPort: 6443
      node132:
        advertiseAddress: 192.168.3.132
        bindPort: 6443

## 删除etcdpod中信息
kubectl exec -it etcd-node130 sh -n kube-system

export ETCDCTL_API=3

alias etcdctl='etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key'

## 获取节点列表
etcdctl member list
ca953a0d64b48849, started, node132, https://192.168.3.132:2380, https://192.168.3.132:2379
df8b283813118626, started, node130, https://192.168.3.130:2380, https://192.168.3.130:2379
ea4c8cb8cc15f00b, started, node131, https://192.168.3.131:2380, https://192.168.3.131:2379
## 删除对应节点
etcdctl member remove 4dc1b8e05e1da44d
Member ea4c8cb8cc15f00b removed from cluster 884edae04b421411
## 再次查看列表
etcdctl member list
ca953a0d64b48849, started, node132, https://192.168.3.132:2380, https://192.168.3.132:2379
df8b283813118626, started, node130, https://192.168.3.130:2380, https://192.168.3.130:2379


## 执行加入节点操作

```


## k8s中的会话保持

- 使用ingress-nginx

会话保持由ingress-nginx-controller提供，请求路径：

客户端 -> ingress-nginx -> pod 

ingress配置中的service仅用于服务发现pod，流量没有经过service

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/affinity: cookie
```


- 直接访问service

会话保持由service提供，请求路径：

客户端 -> service -> pod

service可配置根据ClientIP进行会话保持

```yaml
apiVersion: v1
kind: Service
metadata:
  name: demo
spec:
  ports:
  - name: http
    port: 80
    protocol: TCP
    targetPort: http
  selector:
    app.kubernetes.io/instance: demo
    app.kubernetes.io/name: demo
  sessionAffinity: ClientIP
  sessionAffinityConfig:
    clientIP:
      timeoutSeconds: 10800
  type: ClusterIP
```


## error: Metrics API not available

```shell
[zhdong@k8s-master ~]$ kubectl top no 
error: Metrics API not available
```

```shell
cat << EOF | kubectl create -f -
apiVersion: apiregistration.k8s.io/v1
kind: APIService
metadata:
  labels:
    k8s-app: metrics-server
  name: v1beta1.metrics.k8s.io
spec:
  group: metrics.k8s.io
  groupPriorityMinimum: 100
  insecureSkipTLSVerify: true
  service:
    name: metrics-server
    namespace: kube-system
  version: v1beta1
  versionPriority: 100
EOF


[zhdong@k8s-master ~]$ kubectl api-resources | grep metri
monitormetrics                                          management.cattle.io/v3           true         MonitorMetric
nodes                                                   metrics.k8s.io/v1beta1            false        NodeMetrics
pods                                                    metrics.k8s.io/v1beta1            true         PodMetrics
metricsinstances                                        monitoring.grafana.com/v1alpha1   true         MetricsInstance
```

