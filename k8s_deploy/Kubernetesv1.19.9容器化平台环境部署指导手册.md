## Kubernetesv1.19.9容器化平台环境部署指导手册

https://git.ketanyun.cn/operation/docs/wikis/Kubernetesv1.19.9容器化平台环境部署指导手册

### 部署时注意整改的内容：

1. master高可用改为keepalived+api server，可以去掉nginx，keepalived检测6443端口
2. calico默认采用vxlan模式
3. 以DS方式起ingress controller

### 部署架构根据学校情况调整

- 情况一：域名指向我们ingress;
- 情况二：域名不指向我们的ingress. 针对情况二，不指向我们ingress情况，我们提供多个ingress ,让上游要做负载均衡和健康检查。但是很多情况，学校只给一个node指向。

1. 【方案1：有灾备，无负载均衡】node服务器需要做VIP（1个VIP），把VIP（访问地址）提供给学校，让学校做DNS指向或7层代理指向。
2. 【方案2：代理模式下的负载均衡】如果学校能做到健康检查和负载均衡，我们可以不用VIP,直接将node ip（访问地址）提供学校。
3. 【方案3：DNS模式下的负载均衡】当学校用“方案1”方法无法满足吞吐量的时候，需要提供多组VIP（2台node1个vip，需要4台及以上node服务器数量）。

> 编写手册时，注意将上述方法做区分。

------

本文档删除了传统部署的多活master的HA配置，使用VIP做故障切换

项目主机规划 [主机名_特殊事项_主机地址_pod网络_service网络](https://git.ketanyun.cn/operation/docs/wikis/uploads/a309e5122fcc33de550ca86409f9faf3/主机名_特殊事项_主机地址_pod网络_service网络)

0、主机名规划

```
10.15.6.66 MasterA
10.15.6.75 MasterB
10.15.6.74 MasterC
10.15.6.76 NodeA
10.15.6.77 NodeB
10.15.6.78 NodeC
```

1、更改主机名

```
hostnamectl set-hostname MasterA
hostnamectl set-hostname MasterB
hostnamectl set-hostname MasterC
hostnamectl set-hostname NodeA
hostnamectl set-hostname NodeB
hostnamectl set-hostname NodeC
```

2、执行初始化

```
yum install wget -y

cd /root && mkdir /root/shell && wget http://taskcenter.net/1a2699623e1b8b111676fe63de6551e5 -O /root/shell/init-server.sh

sh /root/shell/init-server.sh

timedatectl set-timezone Asia/Shanghai

yum update -y

升级内核，参考https://linux.cn/article-8310-1.html  *升级内核会导致NFS挂载失败，正式环境升级内核需要注意*
```

3、安装keepalived

```
yum install keepalived -y
```

4、安装docker

```
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum makecache fast

yum install -y docker-ce-18.09.9-3.el7

mkdir -p /etc/docker

cat > /etc/docker/daemon.json <<EOF
{
             "registry-mirrors": ["https://q2uvt0x7.mirror.aliyuncs.com"],
             "data-root": "/data/docker",
             "exec-opts": ["native.cgroupdriver=systemd"],
             "storage-driver": "overlay2", 
             "storage-opts":["overlay2.override_kernel_check=true"],
             "log-driver": "json-file", 
             "log-opts": { 
               "max-size": "100m", 
               "max-file": "10" 
              }
}
EOF

systemctl enable docker && systemctl daemon-reload && systemctl start docker
```

## 5服务器设置白名单

```
假如采用传统请执行一下命令：

systemctl stop firewalld
systemctl mask firewalld

并且安装iptables-services：
yum install iptables-services

设置开机启动：
systemctl enable iptables

iptables启动、关闭、保存：

systemctl [stop|start|restart] iptables
#or
service iptables [stop|start|restart]


service iptables save
#or
/usr/libexec/iptables/iptables.init save
```

### 5.1 MasterA 举例

```
vim /etc/sysconfig/iptables


*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
#这里开始增加白名单服务器ip(请删除当前服务器的ip地址)
-N whitelist
#-A whitelist -s 10.15.6.66 -j ACCEPT
-A whitelist -s 10.15.6.75 -j ACCEPT
-A whitelist -s 10.15.6.74 -j ACCEPT
-A whitelist -s 10.15.6.76 -j ACCEPT
-A whitelist -s 10.15.6.77 -j ACCEPT
-A whitelist -s 10.15.6.78 -j ACCEPT
#这里结束白名单服务器ip
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 30771 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT  
-A INPUT -m state --state NEW -m tcp -p tcp --dport 443 -j ACCEPT 
#上面这些 ACCEPT 端口号，公网内网都可以访问

#下面这些 whitelist 端口号，仅限服务器之间通过内网访问
#这里添加为白名单ip开放的端口
-A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j whitelist
-A INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j whitelist
-A INPUT -m state --state NEW -m tcp -p tcp --dport 443 -j whitelist
-A INPUT -m state --state NEW -m tcp -p tcp --dport 30771 -j whitelist
-A INPUT -m state --state NEW -m tcp -p tcp --dport 8080 -j whitelist
-A INPUT -m state --state NEW -m tcp -p tcp --dport 6443 -j whitelist
#这结束为白名单ip开放的端口
-A INPUT -j REJECT --reject-with icmp-host-prohibited
-A FORWARD -j REJECT --reject-with icmp-host-prohibited

COMMIT
service iptables restart
```

### 5.2 MasterB 举例

```
vim /etc/sysconfig/iptables


*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
#这里开始增加白名单服务器ip(请删除当前服务器的ip地址)
-N whitelist
-A whitelist -s 10.15.6.66 -j ACCEPT
-A whitelist -s 10.15.6.75 -j ACCEPT
#-A whitelist -s 10.15.6.74 -j ACCEPT
-A whitelist -s 10.15.6.76 -j ACCEPT
-A whitelist -s 10.15.6.77 -j ACCEPT
-A whitelist -s 10.15.6.78 -j ACCEPT
#这里结束白名单服务器ip
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 30771 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT  
-A INPUT -m state --state NEW -m tcp -p tcp --dport 443 -j ACCEPT 
#上面这些 ACCEPT 端口号，公网内网都可以访问

#下面这些 whitelist 端口号，仅限服务器之间通过内网访问
#这里添加为白名单ip开放的端口
-A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j whitelist
-A INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j whitelist
-A INPUT -m state --state NEW -m tcp -p tcp --dport 443 -j whitelist
-A INPUT -m state --state NEW -m tcp -p tcp --dport 30771 -j whitelist
-A INPUT -m state --state NEW -m tcp -p tcp --dport 8080 -j whitelist
-A INPUT -m state --state NEW -m tcp -p tcp --dport 6443 -j whitelist
#这结束为白名单ip开放的端口
-A INPUT -j REJECT --reject-with icmp-host-prohibited
-A FORWARD -j REJECT --reject-with icmp-host-prohibited

COMMIT
service iptables restart
```

### 5.3 NodeA 举例

```
vim /etc/sysconfig/iptables


*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
#这里开始增加白名单服务器ip(请删除当前服务器的ip地址)
-N whitelist
-A whitelist -s 10.15.6.66 -j ACCEPT
-A whitelist -s 10.15.6.75 -j ACCEPT
-A whitelist -s 10.15.6.74 -j ACCEPT
#-A whitelist -s 10.15.6.76 -j ACCEPT
-A whitelist -s 10.15.6.77 -j ACCEPT
-A whitelist -s 10.15.6.78 -j ACCEPT
#这里结束白名单服务器ip
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 30771 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT  
-A INPUT -m state --state NEW -m tcp -p tcp --dport 443 -j ACCEPT 
#上面这些 ACCEPT 端口号，公网内网都可以访问

#下面这些 whitelist 端口号，仅限服务器之间通过内网访问
#这里添加为白名单ip开放的端口
-A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j whitelist
-A INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j whitelist
-A INPUT -m state --state NEW -m tcp -p tcp --dport 443 -j whitelist
-A INPUT -m state --state NEW -m tcp -p tcp --dport 30771 -j whitelist
-A INPUT -m state --state NEW -m tcp -p tcp --dport 8080 -j whitelist
-A INPUT -m state --state NEW -m tcp -p tcp --dport 6443 -j whitelist
#这结束为白名单ip开放的端口
-A INPUT -j REJECT --reject-with icmp-host-prohibited
-A FORWARD -j REJECT --reject-with icmp-host-prohibited

COMMIT
service iptables restart
```

### 5.4 NodeB 举例

```
vim /etc/sysconfig/iptables

*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
#这里开始增加白名单服务器ip(请删除当前服务器的ip地址)
-N whitelist
-A whitelist -s 10.15.6.66 -j ACCEPT
# -A whitelist -s 10.15.6.75 -j ACCEPT
-A whitelist -s 10.15.6.74 -j ACCEPT
-A whitelist -s 10.15.6.76 -j ACCEPT
-A whitelist -s 10.15.6.77 -j ACCEPT
-A whitelist -s 10.15.6.78 -j ACCEPT
#这里结束白名单服务器ip
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 30771 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT  
-A INPUT -m state --state NEW -m tcp -p tcp --dport 443 -j ACCEPT 
#上面这些 ACCEPT 端口号，公网内网都可以访问

#下面这些 whitelist 端口号，仅限服务器之间通过内网访问
#这里添加为白名单ip开放的端口
-A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j whitelist
-A INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j whitelist
-A INPUT -m state --state NEW -m tcp -p tcp --dport 443 -j whitelist
-A INPUT -m state --state NEW -m tcp -p tcp --dport 30771 -j whitelist
-A INPUT -m state --state NEW -m tcp -p tcp --dport 8080 -j whitelist
-A INPUT -m state --state NEW -m tcp -p tcp --dport 6443 -j whitelist
#这结束为白名单ip开放的端口
-A INPUT -j REJECT --reject-with icmp-host-prohibited
-A FORWARD -j REJECT --reject-with icmp-host-prohibited

COMMIT
service iptables restart
```

6、下载需要的k8s软件，本文档采用1.19.9

```
yum install -y kubelet-1.19.9 kubeadm-1.19.9 kubectl-1.19.9
```

7、在master上下载编译好的kubeadm二进制文件，暂时在运维的群共享里 https://taskcenter.net/kubeadm

8、配置VIP

使用非抢占模式，防止某个节点的apiserver重启导致频繁故障切换 由于k8s本身对apiserver存在健康检查机制，keepalived本身无需配置健康检查，但需要在计划任务配置脚本检测keepalived本身

```
vi /etc/keepalived/keepalived.conf

! Configuration File for keepalived

global_defs {
   router_id LVS_DEVEL
}

vrrp_instance VI_1 {
    state BACKUP   
    interface eth0  # 网卡名称，CentOS 7 为系统识别总线自生成，以实际网卡名为准
    nopreempt
virtual_router_id 51
    priority 100   # 其他主机修改为100以下
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass HPMOHhWlki  # 认证密码，多个vrrp组请修改此密码
    }
    virtual_ipaddress {
        10.15.6.92/32  # VIP地址
    }
}
```

9、创建kubeadm配置文件

```
vim kubeadm-config.yaml

apiServer:
  certSANs:
  - 10.15.6.66
  - 10.15.6.75
  - 10.15.6.74
  - 10.15.6.92
  timeoutForControlPlane: 4m0s
apiVersion: kubeadm.k8s.io/v1beta2
certificatesDir: /etc/kubernetes/pki
clusterName: kubernetes
controlPlaneEndpoint: "10.15.6.92:6443"   # 修改为VIP地址
controllerManager: {}
dns:
  type: CoreDNS
etcd:
  local:
    dataDir: /var/lib/etcd
imageRepository: oci.ketanyun.cn/hxzhou/kubenetes
kind: ClusterConfiguration
kubernetesVersion: v1.19.9
networking:
  dnsDomain: cluster.local
  serviceSubnet: 172.31.2.0/24  # 按实际需要修改service网络
  podSubnet: "172.31.1.0/24"  # 按实际需要修改pod网络
scheduler: {}
```

10、初始化master（使用新上传的kubeadm，解决证书1年后过期问题）

```
./kubeadm init --config kubeadm-config.yaml --upload-certs
```

11、初始化其他master（使用新上传的kubeadm，解决证书1年后过期问题）

```
./kubeadm join 10.15.6.92:6443 --token 1q3wpz.u1damy0rh12u0l5h \
    --discovery-token-ca-cert-hash sha256:9ceb1590eded8d2ad4404505c4be4d79cc64d4e79a0351aed5bddb938708d40c \
    --control-plane --certificate-key 73bff999c21a8d469e071f146ff0fb283f3d23f72295d00b130abdc12293efe6
```

12、工作节点加入集群（使用新上传的kubeadm，解决证书1年后过期问题）

```
./kubeadm join 10.15.6.92:6443 --token 1q3wpz.u1damy0rh12u0l5h \
    --discovery-token-ca-cert-hash sha256:9ceb1590eded8d2ad4404505c4be4d79cc64d4e79a0351aed5bddb938708d40c
```

13、部署calico网络插件（上传文件做链接）

上传calico定义文件，然后kubectl apply -f 应用

文件位置：https://git.ketanyun.cn/hxzhou/kubenetes/blob/master/calico-vxlan.yaml

14、完成其他部署（rancher、ingress）

（1）ingress-controller

上传ingress定义文件，然后kubectl apply -f 应用

文件位置：https://git.ketanyun.cn/hxzhou/kubenetes/blob/master/ingress-controller.yaml

（2）rancher

```
wget https://get.helm.sh/helm-v3.2.0-linux-amd64.tar.gz
tar zxvf helm-v3.2.0-linux-amd64.tar.gz && mv linux-amd64/helm /usr/bin/helm


helm repo add rancher-stable http://rancher-mirror.oss-cn-beijing.aliyuncs.com/server-charts/stable

kubectl create namespace cattle-system

helm install rancher rancher-stable/rancher \
 --namespace cattle-system \
 --set hostname=10.15.6.93.nip.io  \
 --set ingress.tls.source=secret \
 --set rancherImageTag=v2.5.6

可在项目的windows服务器上访问https://10.15.6.93.nip.io 

Rancher使用方法参见：
https://git.ketanyun.cn/operation/docs/wikis/Rancher%E9%83%A8%E7%BD%B2K8s%E6%8C%87%E5%AF%BC
```