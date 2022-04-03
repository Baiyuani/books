1、主机名规划
10.15.6.66 MasterA
10.15.6.75 MasterB
10.15.6.74 MasterC
10.15.6.76 NodeA
10.15.6.77 NodeB
10.15.6.78 NodeC
2、更改主机名
hostnamectl set-hostname MasterA
hostnamectl set-hostname MasterB
hostnamectl set-hostname MasterC
hostnamectl set-hostname NodeA
hostnamectl set-hostname NodeB
hostnamectl set-hostname NodeC
3、执行初始化
sudo su - root
cd /root && mkdir /root/shell && wget https://taskcenter.net/f27b84ee7e0620b39d03cbfb6a530413 -O /root/shell/init-server.sh
sh /root/shell/init-server.sh
4、在master上下载编译好的kubeadm二进制文件
wget https://taskcenter.net/fb620d15e174ca5cb4388b5a75d1ee18 -O ./kubeadm
5、配置VIP
使用非抢占模式，防止某个节点的apiserver重启导致频繁故障切换 由于k8s本身对apiserver存在健康检查机制，keepalived本身无需配置健康检查，但需要在计划任务配置脚本检测keepalived本身
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
6、创建kubeadm配置文件
vim kubeadm-config.yaml

apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
kubernetesVersion: v1.19.9
controlPlaneEndpoint: "10.15.6.92:6443"
imageRepository: oci.ketanyun.cn/hxzhou/kubenetes
networking:
  dnsDomain: cluster.local
  serviceSubnet: "172.31.2.0/24"
  podSubnet: "172.31.1.0/24"
apiServer:
  certSANs:
  - 10.15.6.66
  - 10.15.6.75
  - 10.15.6.74
  - 10.15.6.92
  timeoutForControlPlane: 4m0s
  extraVolumes:
  - name: localtime
    hostPath: /etc/localtime
    mountPath: /etc/localtime
    readOnly: true
    pathType: File
certificatesDir: /etc/kubernetes/pki
clusterName: kubernetes
controllerManager: 
  extraVolumes:
  - hostPath: /etc/localtime
    mountPath: /etc/localtime
    name: localtime
    readOnly: true
    pathType: File
dns:
  type: CoreDNS
etcd:
  local:
    dataDir: /var/lib/etcd
scheduler: 
  extraVolumes:
  - hostPath: /etc/localtime
    mountPath: /etc/localtime
    name: localtime
    readOnly: true
    pathType: File
---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: "ipvs"
7、初始化master（使用新上传的kubeadm，解决证书1年后过期问题）
./kubeadm init --config kubeadm-config.yaml --upload-certs
8、初始化其他master（使用新上传的kubeadm，解决证书1年后过期问题）
./kubeadm join 10.15.6.92:6443 --token 1q3wpz.u1damy0rh12u0l5h \
    --discovery-token-ca-cert-hash sha256:9ceb1590eded8d2ad4404505c4be4d79cc64d4e79a0351aed5bddb938708d40c \
    --control-plane --certificate-key 73bff999c21a8d469e071f146ff0fb283f3d23f72295d00b130abdc12293efe6
9、工作节点加入集群（使用新上传的kubeadm，解决证书1年后过期问题）
./kubeadm join 10.15.6.92:6443 --token 1q3wpz.u1damy0rh12u0l5h \
    --discovery-token-ca-cert-hash sha256:9ceb1590eded8d2ad4404505c4be4d79cc64d4e79a0351aed5bddb938708d40c
10、部署calico网络插件（上传文件做链接）
上传calico定义文件，然后kubectl apply -f 应用
文件位置：https://git.ketanyun.cn/hxzhou/kubenetes/blob/master/calico-vxlan.yaml
11、完成其他部署（rancher、ingress）
（1）ingress-controller
上传ingress定义文件，然后kubectl apply -f 应用
文件位置：https://git.ketanyun.cn/hxzhou/kubenetes/blob/master/ingress-controller.yaml
（2）rancher
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