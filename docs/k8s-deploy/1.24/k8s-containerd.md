

```shell
hostnamectl set-hostname  k8s-master1
cat >> /etc/hosts<<EOF
192.168.2.11 k8s-master1
EOF
timedatectl set-timezone Asia/Shanghai

#ssh-keygen
#ssh-copy-id -i ~/.ssh/id_rsa.pub root@k8s-master-168-0-113
#ssh-copy-id -i ~/.ssh/id_rsa.pub root@k8s-node1-168-0-114
#ssh-copy-id -i ~/.ssh/id_rsa.pub root@k8s-node2-168-0-115

# ubuntu
cat > /etc/apt/sources.list<<EOF
deb https://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse

deb https://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse

deb https://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse

# deb https://mirrors.aliyun.com/ubuntu/ focal-proposed main restricted universe multiverse
# deb-src https://mirrors.aliyun.com/ubuntu/ focal-proposed main restricted universe multiverse

deb https://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse
EOF
apt update

yum install chrony -y || apt -y install chrony
systemctl start chronyd
systemctl enable chronyd
chronyc sources

systemctl stop firewalld && systemctl disable firewalld || ufw disable

swapoff -a
sed -ri 's/.*swap.*/#&/' /etc/fstab

# centos
# 临时关闭
setenforce 0
# 永久禁用
sed -i 's/^SELINUX=enforcing$/SELINUX=disabled/' /etc/selinux/config

# ipvs
modprobe -- ip_vs
modprobe -- ip_vs_sh
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
lsmod |grep ip_vs
yum install ipset ipvsadm -y || apt -y install ipset ipvsadm

# 允许 iptables 检查桥接流量(可选，所有节点)
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF
sudo modprobe br_netfilter
lsmod | grep br_netfilter
# 设置所需的 sysctl 参数，参数在重新启动后保持不变
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
# 应用 sysctl 参数而不重新启动
sudo sysctl --system

# 添加docker和k8s软件源
bash add_source.sh
apt update

# 安装docker-ce版本
yum install -y docker-ce || apt -y install docker-ce
# 启动
systemctl start docker
# 开机自启
systemctl enable docker
# 查看版本号
docker --version
# 查看版本具体信息
docker version

# Docker镜像源设置
# 修改文件 /etc/docker/daemon.json，没有这个文件就创建
# 添加以下内容后，重启docker服务：
cat >/etc/docker/daemon.json<<EOF
{
  "registry-mirrors": ["https://3muer6q5.mirror.aliyuncs.com"],
  "exec-opts": ["native.cgroupdriver=systemd"],
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
# 加载
systemctl reload docker

# 查看
systemctl status docker containerd

# 导出默认配置，config.toml这个文件默认是不存在的
containerd config default > /etc/containerd/config.toml
grep sandbox_image  /etc/containerd/config.toml
sed -i "s#k8s.gcr.io/pause#registry.aliyuncs.com/google_containers/pause#g" /etc/containerd/config.toml
grep sandbox_image  /etc/containerd/config.toml

sed -i 's#SystemdCgroup = false#SystemdCgroup = true#g' /etc/containerd/config.toml
# 应用所有更改后,重新启动containerd
systemctl restart containerd


cat <<EOF> /etc/crictl.yaml
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 10
debug: false
EOF


#yum install -y kubelet-1.24.4  kubeadm-1.24.4  kubectl-1.24.4 --disableexcludes=kubernetes
apt -y install kubelet=1.24.4-00  kubeadm=1.24.4-00  kubectl=1.24.4-00

# 设置为开机自启并现在立刻启动服务 --now：立刻启动服务
systemctl enable --now kubelet


# 打印配置文件
# kubeadm config print init-defaults --component-configs KubeProxyConfiguration,KubeletConfiguration > kube-config.yaml
kubeadm init --config kube-config.yaml --upload-certs
# 或者
kubeadm init \
--apiserver-advertise-address=192.168.2.11 \
--image-repository registry.aliyuncs.com/google_containers \
--control-plane-endpoint=cluster-endpoint \
--kubernetes-version v1.24.4 \
--service-cidr=172.19.0.0/16 \
--pod-network-cidr=172.18.0.0/16 \
--v=5 --upload-certs
# –image-repository string：    这个用于指定从什么位置来拉取镜像（1.13版本才有的），默认值是k8s.gcr.io，我们将其指定为国内镜像地址：registry.aliyuncs.com/google_containers
# –kubernetes-version string：  指定kubenets版本号，默认值是stable-1，会导致从https://dl.k8s.io/release/stable-1.txt下载最新的版本号，我们可以将其指定为固定版本（v1.22.1）来跳过网络请求。
# –apiserver-advertise-address  指明用 Master 的哪个 interface 与 Cluster 的其他节点通信。如果 Master 有多个 interface，建议明确指定，如果不指定，kubeadm 会自动选择有默认网关的 interface。这里的ip为master节点ip，记得更换。
# –pod-network-cidr             指定 Pod 网络的范围。Kubernetes 支持多种网络方案，而且不同网络方案对  –pod-network-cidr有自己的要求，这里设置为10.244.0.0/16 是因为我们将使用 flannel 网络方案，必须设置成这个 CIDR。
# --control-plane-endpoint     cluster-endpoint 是映射到该 IP 的自定义 DNS 名称，这里配置hosts映射：192.168.0.113   cluster-endpoint。 这将允许你将 --control-plane-endpoint=cluster-endpoint 传递给 kubeadm init，并将相同的 DNS 名称传递给 kubeadm join。 稍后你可以修改 cluster-endpoint 以指向高可用性方案中的负载均衡器的地址。


mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# 临时生效（退出当前窗口重连环境变量失效）
export KUBECONFIG=/etc/kubernetes/admin.conf
# 永久生效（推荐）
echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> ~/.bash_profile
source  ~/.bash_profile

kubectl get po -A


kubectl edit  configmap -n kube-system  kube-proxy
     mode: "ipvs"

# 重启kube-proxy
kubectl get pod -n kube-system | grep kube-proxy
# 再delete让它自拉起
kubectl get pod -n kube-system | grep kube-proxy |awk '{system("kubectl delete pod "$1" -n kube-system")}'
# 再查看
kubectl get pod -n kube-system | grep kube-proxy


ipvsadm -Ln
iptables -nvL


```