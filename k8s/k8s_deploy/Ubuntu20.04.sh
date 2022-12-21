#!/bin/bash

# 配置时区
timedatectl set-timezone Asia/Shanghai

# 关闭自动更新
sed -i s/1/0/g /etc/apt/apt.conf.d/10periodic

# 替换镜像源
cat > /etc/apt/sources.list << EOF
deb http://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse

deb http://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse

deb http://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse

deb http://mirrors.aliyun.com/ubuntu/ focal-proposed main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ focal-proposed main restricted universe multiverse

deb http://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse
EOF

apt-get update -y

# 修改limit参数
echo "* soft nofile 655360" >> /etc/security/limits.conf
echo "* hard nofile 655360" >> /etc/security/limits.conf
echo "root soft nofile 655360" >> /etc/security/limits.conf
echo "root hard nofile 655360" >> /etc/security/limits.conf
echo "* soft nproc 655360"  >> /etc/security/limits.conf
echo "* hard nproc 655360"  >> /etc/security/limits.conf
echo "* soft  memlock  unlimited"  >> /etc/security/limits.conf
echo "* hard memlock  unlimited"  >> /etc/security/limits.conf
echo "DefaultLimitNOFILE=1024000"  >> /etc/systemd/system.conf
echo "DefaultLimitNPROC=1024000"  >> /etc/systemd/system.conf

# 禁用swap分区
swapoff -a && echo "vm.swappiness = 0">> /etc/sysctl.conf

mv /etc/fstab /etc/fstab_bak
cat /etc/fstab_bak |grep -v swap > /etc/fstab


# 修改内核参数
echo 'net.bridge.bridge-nf-call-ip6tables = 1' >>  /etc/sysctl.d/k8s.conf
echo 'net.bridge.bridge-nf-call-iptables = 1' >> /etc/sysctl.d/k8s.conf
echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.d/k8s.conf
modprobe br_netfilter
sysctl -p /etc/sysctl.d/k8s.conf

# 开启IPVS
for i in $(ls /lib/modules/$(uname -r)/kernel/net/netfilter/ipvs|grep -o "^[^.]*");do echo $i; sudo /sbin/modinfo -F filename $i >/dev/null 2>&1 && /sbin/modprobe $i; done
ls /lib/modules/$(uname -r)/kernel/net/netfilter/ipvs|grep -o "^[^.]*" >> /etc/modules

# 安装必要软件
apt-get install -y lrzsz wget curl net-tools vim ipset ipvsadm lvm2 telnet keepalived nfs-kernel-server

# 安装docker
apt-get update
apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository \
	     "deb [arch=amd64] https://mirrors.aliyun.com/docker-ce/linux/ubuntu \
	          $(lsb_release -cs) \
		       stable"

apt-get install -y docker-ce=5:19.03.15~3-0~ubuntu-focal docker-ce-cli=5:19.03.15~3-0~ubuntu-focal containerd.io

mkdir -p /etc/docker

cat > /etc/docker/daemon.json <<EOF
{
             "registry-mirrors": ["https://3muer6q5.mirror.aliyuncs.com"],
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

systemctl enable docker && systemctl daemon-reload && systemctl restart docker

# 安装kubernetes
curl https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | sudo apt-key add -

cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main
EOF
apt-get update -y
apt-get install -y kubelet=1.19.9-00 kubeadm=1.19.9-00 kubectl=1.19.9-00

