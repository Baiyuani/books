## 一、调整逻辑分区(MasterA,NodeA,NodeB)
#### 1.调整说明
```shell script
/dev/mapper/centos-root   50G  --> 80G
/dev/mapper/centos-home   42G  --> 10G
```
#### 2.操作步骤
- 2.1 取消挂载
```shell script
[root@MasterA ~]# vi /etc/fstab
#/dev/mapper/centos-home /home                   xfs     defaults        0 0
[root@MasterA ~]# umount /home
[root@MasterA ~]# df -h
文件系统                 容量  已用  可用 已用% 挂载点
devtmpfs                  16G     0   16G    0% /dev
tmpfs                     16G     0   16G    0% /dev/shm
tmpfs                     16G  8.9M   16G    1% /run
tmpfs                     16G     0   16G    0% /sys/fs/cgroup
/dev/mapper/centos-root   50G  1.4G   49G    3% /
/dev/sda1               1014M  150M  865M   15% /boot
tmpfs                    3.2G     0  3.2G    0% /run/user/0
```
- 2.2 重新创建lv：centos-home,格式化
```shell script
[root@MasterA ~]# lvremove /dev/mapper/centos-home 
Do you really want to remove active logical volume centos/home? [y/n]: y
  Logical volume "home" successfully removed
[root@MasterA ~]# lvcreate -L 10G -n home centos
WARNING: xfs signature detected on /dev/centos/home at offset 0. Wipe it? [y/n]: y
  Wiping xfs signature on /dev/centos/home.
  Logical volume "home" created.
[root@MasterA ~]# lvs
  LV   VG     Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  home centos -wi-a----- 10.00g                                                    
  root centos -wi-ao---- 50.00g                                                    
  swap centos -wi-ao---- <7.88g  
[root@MasterA ~]# mkfs.xfs /dev/mapper/centos-home 
meta-data=/dev/mapper/centos-home isize=512    agcount=4, agsize=655360 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0, sparse=0
data     =                       bsize=4096   blocks=2621440, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal log           bsize=4096   blocks=2560, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
[root@MasterA ~]# vi /etc/fstab
/dev/mapper/centos-home /home                   xfs     defaults        0 0
[root@MasterA ~]# mount -a
[root@MasterA ~]# df -h
文件系统                 容量  已用  可用 已用% 挂载点
devtmpfs                 3.9G     0  3.9G    0% /dev
tmpfs                    3.9G     0  3.9G    0% /dev/shm
tmpfs                    3.9G  8.9M  3.9G    1% /run
tmpfs                    3.9G     0  3.9G    0% /sys/fs/cgroup
/dev/mapper/centos-root   50G  1.4G   49G    3% /
/dev/sda1               1014M  150M  865M   15% /boot
tmpfs                    783M     0  783M    0% /run/user/0
/dev/mapper/centos-home   10G   33M   10G    1% /home
- 2.3 扩展lv：centos-root,刷新文件系统
[root@MasterA ~]# lvextend -L 80G /dev/mapper/centos-root 
  Size of logical volume centos/root changed from 50.00 GiB (12800 extents) to 80.00 GiB (20480 extents).
  Logical volume centos/root successfully resized.
[root@MasterA ~]# xfs_growfs /dev/mapper/centos-root 
meta-data=/dev/mapper/centos-root isize=512    agcount=4, agsize=3276800 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0 spinodes=0
data     =                       bsize=4096   blocks=13107200, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal               bsize=4096   blocks=6400, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
data blocks changed from 13107200 to 20971520
[root@MasterA ~]# df -h
文件系统                 容量  已用  可用 已用% 挂载点
devtmpfs                 3.9G     0  3.9G    0% /dev
tmpfs                    3.9G     0  3.9G    0% /dev/shm
tmpfs                    3.9G  8.9M  3.9G    1% /run
tmpfs                    3.9G     0  3.9G    0% /sys/fs/cgroup
/dev/mapper/centos-root   80G  1.4G   79G    2% /
/dev/sda1               1014M  150M  865M   15% /boot
tmpfs                    783M     0  783M    0% /run/user/0
/dev/mapper/centos-home   10G   33M   10G    1% /home
```

## 二、部署k8s（MasterA）
#### 1.关闭、禁用防火墙：
```shell script
systemctl disable --now firewalld
```
#### 2.禁用SELINUX：
```shell script
sed  -i  '7s/enforcing/disabled/' /etc/selinux/config
setenforce 0
getenforce
```
##### 3.关闭交换分区
```shell script
sed -i '12s/^/#/' /etc/fstab
swapoff -a
```
##### 4.添加hosts
```shell script
cat >> /etc/hosts <<- EOF
10.1.2.32 ExportAPI
10.1.2.27 MasterA
10.1.2.28 NodeA
10.1.2.31 NodeB
10.1.2.29 StorageA
10.1.2.30 StorageB
EOF
```
#### 5.创建 /etc/sysctl.d/k8s.conf 文件，生效配置
```shell script
cat << EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

modprobe br_netfilter 
sysctl -p /etc/sysctl.d/k8s.conf
```
#### 6.配置阿里云yum源
```shell script
curl -o /etc/yum.repos.d/Centos-7.repo http://mirrors.aliyun.com/repo/Centos-7.repo
curl -o /etc/yum.repos.d/docker-ce.repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg
        http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

yum clean all && yum makecache
```
#### 7.安装 Docker
```shell script
yum -y install docker-ce
systemctl enable --now docker
```
#### 8.安装 kubelet kubeadm kubectl
```shell script
yum install -y kubectl-1.18.4 kubeadm-1.18.4 kubelet-1.18.4
```
#### 9.设置kubectl、kubeadm的Tab补齐
```shell script
kubectl completion bash >/etc/bash_completion.d/kubectl
kubeadm completion bash >/etc/bash_completion.d/kubeadm
exit
```
#### 10.master安装ipvsadm ipset
```shell script
yum -y install ipvsadm ipset
```
#### 11.配置阿里云镜像加速器，并指向镜像仓库
```shell script
mkdir -p /etc/docker
tee /etc/docker/daemon.json <<-'EOF'
{
    "exec-opts": ["native.cgroupdriver=systemd"],
    "registry-mirrors": [
    "https://obww7jh1.mirror.aliyuncs.com",
    "https://8xpk5wnt.mirror.aliyuncs.com",
    "https://dockerhub.azk8s.cn",
    "https://registry.docker-cn.com",
    "https://ot2k4d59.mirror.aliyuncs.com/"
]
}
EOF

systemctl daemon-reload && systemctl restart docker
```
#### 12.镜像上传
- 12.1 查看需要镜像
```shell script
[root@k8s-master ~]# kubeadm  config images list
k8s.gcr.io/kube-apiserver:v1.18.4
k8s.gcr.io/kube-controller-manager:v1.18.4  
k8s.gcr.io/kube-scheduler:v1.18.4     ·
k8s.gcr.io/kube-proxy:v1.18.4
k8s.gcr.io/pause:3.2
k8s.gcr.io/etcd:3.4.3-0
k8s.gcr.io/coredns:1.6.7
```
- 12.2 拉取gotok8s的镜像
```shell script
export image=kube-apiserver:v1.18.4
docker pull gotok8s/${image}
docker tag gotok8s/${image} k8s.gcr.io/${image}
docker rmi gotok8s/${image}

export image=kube-controller-manager:v1.18.4
docker pull gotok8s/${image}
docker tag gotok8s/${image} k8s.gcr.io/${image}
docker rmi gotok8s/${image}

export image=kube-scheduler:v1.18.4
docker pull gotok8s/${image}
docker tag gotok8s/${image} k8s.gcr.io/${image}
docker rmi gotok8s/${image}

export image=kkube-proxy:v1.18.4
docker pull gotok8s/${image}
docker tag gotok8s/${image} k8s.gcr.io/${image}
docker rmi gotok8s/${image}

export image=pause:3.2
docker pull gotok8s/${image}
docker tag gotok8s/${image} k8s.gcr.io/${image}
docker rmi gotok8s/${image}

export image=etcd:3.4.3-0
docker pull gotok8s/${image}
docker tag gotok8s/${image} k8s.gcr.io/${image}
docker rmi gotok8s/${image}

export image=coredns:1.6.7
docker pull gotok8s/${image}
docker tag gotok8s/${image} k8s.gcr.io/${image}
docker rmi gotok8s/${image}
```
#### 13.初始化集群
- 13.1 测试初始化
```shell script
kubeadm init --dry-run
```
- 13.2 导出配置文件
```shell script
kubeadm config print init-defaults >kubeadm-init.yaml
```
- 13.3 修改配置文件
```shell script
[root@MasterA ~]# vi kubeadm-init.yaml 
  token: abcdef.0123456789abcdef
  ttl: 24h0m0s      #token周期
  usages:
  - signing
  - authentication
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: 10.1.2.27       #apiserver地址
  bindPort: 6443
nodeRegistration:
  criSocket: /var/run/dockershim.sock
  name: mastera
  taints:
  - effect: NoSchedule
    key: node-role.kubernetes.io/master
---
apiServer:
  timeoutForControlPlane: 4m0s
apiVersion: kubeadm.k8s.io/v1beta2
certificatesDir: /etc/kubernetes/pki
clusterName: kubernetes
controllerManager: {}
dns:
  type: CoreDNS
etcd:
  local:
    dataDir: /var/lib/etcd
imageRepository: k8s.gcr.io     #镜像仓库地址
kind: ClusterConfiguration
kubernetesVersion: v1.18.4      #k8s版本
networking:
  dnsDomain: cluster.local
  podSubnet: 192.168.0.0/16     #容器地址cidr
  serviceSubnet: 10.101.0.0/16  #服务地址cidr
scheduler: {}
```
- 13.4 初始化集群
```shell script
[root@MasterA ~]# kubeadm init --config=kubeadm-init.yaml | tee master-init.log
··· ····
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 10.1.2.27:6443 --token abcdef.0123456789abcdef \
    --discovery-token-ca-cert-hash sha256:402a5cb9c1c301b27cf0fb7fd747a9d62cdfb6cff1db7a7c3536a623a5e3817f
```
 - 13.5 根据初始化提示   
 ``` shell script
[root@MasterA ~]# mkdir -p $HOME/.kube
[root@MasterA ~]# sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
[root@MasterA ~]# sudo chown $(id -u):$(id -g) $HOME/.kube/config 
 ``` 
- 13.5 查看master状态
```shell script
[root@MasterA ~]# kubectl  get nodes
NAME      STATUS     ROLES    AGE     VERSION
mastera   NotReady   master   2m23s   v1.18.4
```
#### 14.企业级网络
```shell script
curl https://docs.projectcalico.org/manifests/calico.yaml -O
kubectl apply -f calico.yaml
```
## 三、添加Node节点(NodeA,NodeB,StorageA,StorageB,ExportAPI)
#### Node脚本
    ##/bin/bash
    systemctl disable --now   firewalld
    
    sed  -i  '7s/enforcing/disabled/' /etc/selinux/config
    setenforce 0
    
    sed -i '12s/^/#/' /etc/fstab
    swapoff -a
    
    cat >> /etc/hosts <<- EOF
    10.1.2.32 ExportAPI
    10.1.2.27 MasterA
    10.1.2.28 NodeA
    10.1.2.31 NodeB
    10.1.2.29 StorageA
    10.1.2.30 StorageB
    EOF
    
    cat << EOF > /etc/sysctl.d/k8s.conf
    net.bridge.bridge-nf-call-ip6tables = 1
    net.bridge.bridge-nf-call-iptables = 1
    net.ipv4.ip_forward = 1
    EOF
    
    modprobe br_netfilter 
    sysctl -p /etc/sysctl.d/k8s.conf
    
    curl -o /etc/yum.repos.d/Centos-7.repo http://mirrors.aliyun.com/repo/Centos-7.repo
    curl -o /etc/yum.repos.d/docker-ce.repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
    
    cat <<EOF > /etc/yum.repos.d/kubernetes.repo
    [kubernetes]
    name=Kubernetes
    baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
    enabled=1
    gpgcheck=0
    repo_gpgcheck=0
    gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg
            http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
    EOF
    
    yum clean all && yum makecache
    
    yum -y install docker-ce
    systemctl enable --now docker
    
    yum install -y kubectl-1.18.4 kubeadm-1.18.4 kubelet-1.18.4
    
    kubectl completion bash >/etc/bash_completion.d/kubectl
    kubeadm completion bash >/etc/bash_completion.d/kubeadm
    
    yum -y install ipvsadm ipset
    
    mkdir -p /etc/docker
    tee /etc/docker/daemon.json <<-'EOF'
    {
        "exec-opts": ["native.cgroupdriver=systemd"],
        "registry-mirrors": [
        "https://obww7jh1.mirror.aliyuncs.com",
        "https://8xpk5wnt.mirror.aliyuncs.com",
        "https://dockerhub.azk8s.cn",
        "https://registry.docker-cn.com",
        "https://ot2k4d59.mirror.aliyuncs.com/"
    ]
    }
    EOF
    systemctl daemon-reload && systemctl restart docker
    
    export image=pause:3.2
    docker pull gotok8s/${image}
    docker tag gotok8s/${image} k8s.gcr.io/${image}
    docker rmi gotok8s/${image}
    
    export image=kube-proxy:v1.18.4
    docker pull gotok8s/${image}
    docker tag gotok8s/${image} k8s.gcr.io/${image}
    docker rmi gotok8s/${image}
    
    export image=coredns:1.6.7
    docker pull gotok8s/${image}
    docker tag gotok8s/${image} k8s.gcr.io/${image}
    docker rmi gotok8s/${image}
    
    kubeadm join 10.1.2.27:6443 --token abcdef.0123456789abcdef \
        --discovery-token-ca-cert-hash sha256:402a5cb9c1c301b27cf0fb7fd747a9d62cdfb6cff1db7a7c3536a623a5e3817f
## 四、MasterA安装Helm  
#### 1.Helm软件包下载
```shell script
$cd /tmp
wget https://get.helm.sh/helm-v3.3.1-linux-amd64.tar.gz
```
#### 2.解压软件包
```shell script
tar -zxvf helm-v3.3.1-linux-amd64.tar.gz
cd linux-amd64/
```
#### 3.更换路径
```shell script
mv helm  /usr/local/bin/helm
```
#### 添加仓库
```shell script
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add stable https://kubernetes-charts.storage.googleapis.com
```   
    
    
    
    
    




