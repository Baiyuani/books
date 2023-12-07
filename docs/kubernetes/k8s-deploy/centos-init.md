```bash
## all vm

vim /etc/hosts
mkdir .ssh
mv rsa.pem .ssh/id_rsa
mv authorized_keys .ssh/
chmod 0400 .ssh/*
sed -ri "59i StrictHostKeyChecking no" /etc/ssh/ssh_config || true
sed -ri "59i UserKnownHostsFile /dev/null" /etc/ssh/ssh_config || true
echo "Host *
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null" > /etc/ssh/ssh_config.d/my.conf || true
systemctl restart sshd

# 关闭SELINUX
sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config
setenforce 0

# 修改limit参数
echo "* soft nofile 655360" >> /etc/security/limits.conf
echo "* hard nofile 655360" >> /etc/security/limits.conf
echo "* soft nproc 655360"  >> /etc/security/limits.conf
echo "* hard nproc 655360"  >> /etc/security/limits.conf
echo "* soft  memlock  unlimited"  >> /etc/security/limits.conf
echo "* hard memlock  unlimited"  >> /etc/security/limits.conf
echo "DefaultLimitNOFILE=1024000"  >> /etc/systemd/system.conf
echo "DefaultLimitNPROC=1024000"  >> /etc/systemd/system.conf

# 关闭防火墙
systemctl stop firewalld && systemctl disable firewalld

# 禁用swap分区
swapoff -a && echo "vm.swappiness = 0">> /etc/sysctl.conf
vim /etc/fstab

# 修改内核参数
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
modprobe br_netfilter
sysctl -p /etc/sysctl.d/k8s.conf

# 开启IPVS
cat > /etc/sysconfig/modules/ipvs.modules <<EOF
#!/bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4
EOF

chmod 755 /etc/sysconfig/modules/ipvs.modules && bash /etc/sysconfig/modules/ipvs.modules && lsmod | grep -e ip_vs -e nf_conntrack_ipv4

# 安装必要的软件
yum repolist
yum install -y git lrzsz wget curl net-tools vim ipset ipvsadm yum-utils device-mapper-persistent-data lvm2 telnet nfs-utils

# 配置镜像源
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

timedatectl set-timezone Asia/Shanghai
yum update -y
mkdir /data

#安装docker
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum makecache fast

yum install -y docker-ce-18.09.9-3.el7
mkdir -p /etc/docker
cat > /etc/docker/daemon.json <<EOF
{
  "registry-mirrors": ["https://3muer6q5.mirror.aliyuncs.com"],
  "exec-opts": ["native.cgroupdriver=cgroupfs"],
#  "exec-opts": ["native.cgroupdriver=systemd"],
  "data-root": "/data/docker",
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

#安装kube
yum install -y kubelet-1.19.9 kubeadm-1.19.9 kubectl-1.19.9 && systemctl enable kubelet


## 不同机器参数不同
nmtui
hostnamectl set-hostname master|node


# master
vim kubeadm-config.yaml

apiServer:
  certSANs:
  - 192.168.0.11
  timeoutForControlPlane: 4m0s
apiVersion: kubeadm.k8s.io/v1beta2
certificatesDir: /etc/kubernetes/pki
clusterName: kubernetes
controlPlaneEndpoint: "192.168.0.11:6443"   # 如果使用keepalived做高可用，则修改为VIP地址
controllerManager: {}
dns:
  type: CoreDNS
etcd:
  local:
    dataDir: /data/etcd
imageRepository: oci.ketanyun.cn/zhdong/k8s
kind: ClusterConfiguration
kubernetesVersion: v1.19.9
netwo
rking:
  dnsDomain: cluster.local
  serviceSubnet: 172.31.2.0/24  # 按实际需要修改service网络
  podSubnet: "172.31.1.0/24"  # 按实际需要修改pod网络
scheduler: {}

#初始化集群
docker pull oci.ketanyun.cn/zhdong/k8s/pause:3.2
docker pull oci.ketanyun.cn/zhdong/k8s/coredns:1.7.0
docker pull oci.ketanyun.cn/zhdong/k8s/etcd:3.4.13-0
docker pull oci.ketanyun.cn/zhdong/k8s/kube-apiserver:v1.19.9
docker pull oci.ketanyun.cn/zhdong/k8s/kube-scheduler:v1.19.9
docker pull oci.ketanyun.cn/zhdong/k8s/kube-controller-manager:v1.19.9
docker pull oci.ketanyun.cn/zhdong/k8s/kube-proxy:v1.19.9
docker pull oci.ketanyun.cn/zhdong/k8s/kube-controllers:v3.19.1
docker pull oci.ketanyun.cn/zhdong/k8s/cni:v3.19.1
docker pull oci.ketanyun.cn/zhdong/k8s/pod2daemon-flexvol:v3.19.1
docker pull oci.ketanyun.cn/zhdong/k8s/node:v3.19.1

./kubeadm init --config kubeadm-config.yaml --upload-certs

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

You can now join any number of the control-plane node running the following command on each as root:

  kubeadm join 192.168.0.11:6443 --token 39fnj7.wppktox08qk4799t \
    --discovery-token-ca-cert-hash sha256:7e75028528c15e2d62dc3c8a729b04808f086ed3fbea096539a0ea629f3c2ced \
    --control-plane --certificate-key 8f63d58ab0c42ce0424ba25b6e319e87f55752f2f284217809a7f060f3ef8cd2

Please note that the certificate-key gives access to cluster sensitive data, keep it secret!
As a safeguard, uploaded-certs will be deleted in two hours; If necessary, you can use
"kubeadm init phase upload-certs --upload-certs" to reload certs afterward.

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.0.11:6443 --token mkfx10.hjw8sa2xf59bgs24 \
    --discovery-token-ca-cert-hash sha256:7e75028528c15e2d62dc3c8a729b04808f086ed3fbea096539a0ea629f3c2ced

#配置kubectl
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
  
#部署插件
kubectl apply -f calico-vxlan.yaml  
kubectl apply -f ingress-controller.yaml 

#kubectl补全
source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >> ~/.bashrc
source <(kubeadm completion bash)
echo "source <(kubeadm completion bash)" >> ~/.bashrc

#helm
wget https://get.helm.sh/helm-v3.2.0-linux-amd64.tar.gz
tar -xf helm-v3.2.0-linux-amd64.tar.gz
cp -p linux-amd64/helm /usr/bin/
source <(helm completion bash)
echo "source <(helm completion bash)" >> ~/.bashrc
```

