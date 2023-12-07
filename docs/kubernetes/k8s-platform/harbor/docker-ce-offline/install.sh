#!/usr/bin/env bash

# rpm包下载：https://download.docker.com/linux/centos/7/x86_64/stable/Packages/  放到./packages中
#
# 操作系统支持：
#   Anolis 8.6/8.8
#   CentOS 7/8


centos() {
  # 关闭selinux
  sed -i '/SELINUX=/c SELINUX=disabled' /etc/selinux/config
  setenforce 0

  yum -y remove docker \
                    docker-client \
                    docker-client-latest \
                    docker-common \
                    docker-latest \
                    docker-latest-logrotate \
                    docker-logrotate \
                    docker-engine

  # Anolis8 卸载runc
  if grep "^NAME" /etc/os-release | grep -iq "anolis" && rpm -qa | grep -q runc;then
    rpm -e runc containers-common podman buildah podman-catatonit cockpit-podman || true
  fi
  if rpm -qa | grep -q containerd;then
    rpm -e containerd.io
  fi
  rpm -ivh --force ./packages/*.rpm

}


debian() {
  # 关闭自动更新
  sed -i s/1/0/g /etc/apt/apt.conf.d/10periodic || true

  tar -xvf ./packages/sources_list.tar.gz -C /etc/apt
  tar -xvf ./packages/sources_list_d.tar.gz -C /etc/apt/sources.list.d
  tar -xvf ./packages/sources_list_lib.tar.gz -C /var/lib/apt/lists
  tar -xvf ./packages/sources_softs.tar.gz -C /var/cache/apt/archives

  apt-get -y install docker-ce docker-ce-cli docker-compose-plugin docker-buildx-plugin containerd.io docker-ce-rootless-extras

}


# 修改内核参数
modify_sysctlconf(){
    key=$1
    value=$2
    if [[ $(grep $key /etc/sysctl.conf) ]];then
        sed -i "/${key}/d" /etc/sysctl.conf
    fi
    echo "$key = $value" >> /etc/sysctl.conf
}
#modify_sysctlconf vm.swappiness 0
#modify_sysctlconf net.ipv4.ip_forward 1
#modify_sysctlconf net.bridge.bridge-nf-call-ip6tables 1
#modify_sysctlconf net.bridge.bridge-nf-call-iptables 1
modify_sysctlconf kernel.pid_max 4194304
sysctl -p

# 修改limit参数
if ! grep 'soft nofile 655360' /etc/security/limits.conf &> /dev/null;then
  echo '* soft nofile 655360
* hard nofile 655360
root soft nofile 655360
root hard nofile 655360
root soft nproc 655360
root hard nproc 655360
* soft nproc 655360
* hard nproc 655360
* soft  memlock  unlimited
* hard memlock  unlimited' >> /etc/security/limits.conf
  echo 'DefaultLimitNOFILE=1024000
DefaultLimitNPROC=1024000' >> /etc/systemd/system.conf
fi

timedatectl set-timezone Asia/Shanghai


if grep "^NAME" /etc/os-release | grep -iq "openEuler" ;then
  centos
elif grep "^NAME" /etc/os-release | grep -iq "centos" ;then
  centos
elif grep "^NAME" /etc/os-release | grep -iq "ubuntu" ;then
  debian
elif grep "^NAME" /etc/os-release | grep -iq "anolis" ;then
  centos
elif grep "^NAME" /etc/os-release | grep -iq "UnionTech" ;then
  centos
fi




cat << EOF > /etc/docker/daemon.json
{
  "registry-mirrors": ["https://3muer6q5.mirror.aliyuncs.com"],
  "insecure-registries": [
    "0.0.0.0/0"
  ],
  "bip": "10.223.233.1/24",
  "exec-opts": ["native.cgroupdriver=systemd"],
  "data-root": "/var/lib/docker",
  "storage-driver": "overlay2",
  "log-driver": "json-file",
  "log-opts": {
      "max-size": "100m",
      "max-file": "10"
  }
}
EOF

systemctl enable docker --now

