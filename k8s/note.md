# 镜像仓库凭证
1. 创建imagePullSecret，并**覆盖旧的**
kubectl create secret docker-registry registry -n ketanyun --docker-server=docker.qtgl.com.cn --docker-username=xx --docker-password=xx --dry-run=client -oyaml | kubectl apply -f-

2. 已有镜像仓库
docker.qtgl.com.cn 
oci.ketanyun.cn



# 配置kubectl命令行补全

```
source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >> ~/.bashrc
```


# dashboard登录token生成
dashboard创建用户，生成token

kubectl create sa dashboard-admin -n kube-system

给用户绑定角色

kubectl create clusterrolebinding dashboard-admin --clusterrole=cluster-admin --serviceaccount=kube-system:dashboard-admin

查看用户的token：

kubectl describe secrets -n kube-system $(kubectl -n kube-system get secret | awk '/dashboard-admin/{print $1}')







# [kubectl 使用token的方式连接到集群](https://www.cnblogs.com/AnAng/p/12056963.html)

首先得有一个账户

```
kubectl create serviceaccount dashboard-admin -n kube-system #创建一个名叫dashboard-admin 命名空间在kube-system 下的服务账户
kubectl create clusterrolebinding dashboard-admin --clusterrole=cluster-admin --serviceaccount=kube-system:dashboard-admin #dashboard-admin 绑定为集群账户
kubectl describe secrets -n kube-system $(kubectl -n kube-system get secret | awk '/dashboard-admin/{print $1}') #显示出名字为dashboard-admin-*的第一个匹配账户的详细信息
```

这里创建一个用来登录kubernetes的账户 

如果有直接执行第三条命令取出token

```
 kubectl config set-credentials tf-admin --token={上文的Token} #配置登录方式 这里我使用的是token登录 通过kubectl describe secrets -n kube-system $(kubectl -n kube-system get secret | awk '/dashboard-admin/{print $1}') 命令可以查看一条
 kubectl config set-cluster tf-cluster --insecure-skip-tls-verify=true --server={集群的连接地址https://xx.xx.xx.xx:xx} #配置连接地址
 kubectl config set-context tf-system --cluster=tf-cluster --user=tf-admin 
 kubectl config use-context tf-system  
```





# k8s集群添加新节点

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



# Unable to connect to the server: x509: certificate is valid for ingress.local
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

# 重置节点后的操作

rm -rf /etc/kubernetes/* && rm -rf ~/.kube/* && rm -rf /var/lib/etcd/*



# taint

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



# 修改kubelet和etcd的存储目录
https://blog.csdn.net/qq_39826987/article/details/126473129

# coredns配置泛域名hosts

```shell
apiVersion: v1
data:
  Corefile: |
    .:53 {
        errors
        health {
           lameduck 5s
        }
        ready
        hosts {
           192.168.0.204 kas.baiyuani.top minio.baiyuani.top registry.baiyuani.top gitlab.baiyuani.top harbor.baiyuani.top
           fallthrough
        }
        template IN A dzh.com {
          match .*\.dzh\.com
          answer "{{ .Name }} 60 IN A 192.168.1.1"
          fallthrough
        }
        kubernetes cluster.local in-addr.arpa ip6.arpa {
           pods insecure
           fallthrough in-addr.arpa ip6.arpa
           ttl 30
        }
        prometheus :9153
        forward . /etc/resolv.conf {
           max_concurrent 1000
        }
        cache 30
        loop
        reload
        loadbalance
    }
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
```

# coredns 配置dns
```yaml
apiVersion: v1
data:
  Corefile: |
    .:53 {
        errors
        health {
           lameduck 5s
        }
        ready
        hosts {
           192.168.110.183 my-sso.saif.sjtu.edu.cn
           fallthrough
        }
        kubernetes cluster.local in-addr.arpa ip6.arpa {
           pods insecure
           fallthrough in-addr.arpa ip6.arpa
           ttl 30
        }
        prometheus :9153
        forward . /etc/resolv.conf {
           max_concurrent 1000
        }
        cache 30
        loop
        reload
        loadbalance
    }
    saifdc1.saif.com:53 {
      errors
      cache 30
      forward . 172.16.110.11
      reload
    }
    saifdc2.saif.com:53 {
      errors
      cache 30
      forward . 172.16.110.12
      reload
    }
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system

```

# ingress-nginx 代理外部域名
```yaml
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
#    nginx.ingress.kubernetes.io/backend-protocol: HTTPS
    nginx.ingress.kubernetes.io/rewrite-target: /$2
    nginx.ingress.kubernetes.io/upstream-vhost: prometheus.baiyuani.top
    nginx.ingress.kubernetes.io/use-regex: "true"
  name: test
  namespace: dev
spec:
  ingressClassName: nginx
  rules:
  - host: test.baiyuani.top
    http:
      paths:
      - backend:
          service:
            name: test
            port:
              number: 80
        path: /test(/|$)(.*)
        pathType: ImplementationSpecific
#  tls:
#  - hosts:
#    - 'test.baiyuani.top'
#    secretName: domain-tls

---
apiVersion: v1
kind: Service
metadata:
  name: test
  namespace: dev
spec:
  externalName: prometheus.baiyuani.top
  sessionAffinity: None
  type: ExternalName

```