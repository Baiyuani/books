#!/usr/bin/env bash


# 下载目录
WORKDIR=$(dirname $(readlink -f "$0"))
PKGDIR="${WORKDIR}/packages"


centos() {
  echo '[docker-ce-stable]
name=Docker CE Stable - $basearch
baseurl=https://mirrors.aliyun.com/docker-ce/linux/centos/$releasever/$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/docker-ce/linux/centos/gpg

[docker-ce-stable-debuginfo]
name=Docker CE Stable - Debuginfo $basearch
baseurl=https://mirrors.aliyun.com/docker-ce/linux/centos/$releasever/debug-$basearch/stable
enabled=0
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/docker-ce/linux/centos/gpg

[docker-ce-stable-source]
name=Docker CE Stable - Sources
baseurl=https://mirrors.aliyun.com/docker-ce/linux/centos/$releasever/source/stable
enabled=0
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/docker-ce/linux/centos/gpg

[docker-ce-test]
name=Docker CE Test - $basearch
baseurl=https://mirrors.aliyun.com/docker-ce/linux/centos/$releasever/$basearch/test
enabled=0
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/docker-ce/linux/centos/gpg

[docker-ce-test-debuginfo]
name=Docker CE Test - Debuginfo $basearch
baseurl=https://mirrors.aliyun.com/docker-ce/linux/centos/$releasever/debug-$basearch/test
enabled=0
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/docker-ce/linux/centos/gpg

[docker-ce-test-source]
name=Docker CE Test - Sources
baseurl=https://mirrors.aliyun.com/docker-ce/linux/centos/$releasever/source/test
enabled=0
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/docker-ce/linux/centos/gpg

[docker-ce-nightly]
name=Docker CE Nightly - $basearch
baseurl=https://mirrors.aliyun.com/docker-ce/linux/centos/$releasever/$basearch/nightly
enabled=0
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/docker-ce/linux/centos/gpg

[docker-ce-nightly-debuginfo]
name=Docker CE Nightly - Debuginfo $basearch
baseurl=https://mirrors.aliyun.com/docker-ce/linux/centos/$releasever/debug-$basearch/nightly
enabled=0
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/docker-ce/linux/centos/gpg

[docker-ce-nightly-source]
name=Docker CE Nightly - Sources
baseurl=https://mirrors.aliyun.com/docker-ce/linux/centos/$releasever/source/nightly
enabled=0
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/docker-ce/linux/centos/gpg
' > /etc/yum.repos.d/docker-ce.repo

  if grep -iq "openEuler" /etc/os-release;then
    sed -i 's/$releasever/7/g' /etc/yum.repos.d/docker-ce.repo
  fi


  yum makecache

  # 安装yum-utils
  yum -y install yum-utils

  if grep "^NAME" /etc/os-release | grep -iq "anolis" ;then
    
    cd "${PKGDIR}" && repotrack  docker-ce docker-ce-cli docker-compose-plugin docker-buildx-plugin containerd.io docker-ce-rootless-extras \
          cyrus-sasl-plain device-mapper-event  openssl  rpm-build-libs systemd-sysv  lvm2-libs lvm2

    yumdownloader --destdir="${PKGDIR}" --resolve \
          docker-ce docker-ce-cli docker-compose-plugin docker-buildx-plugin containerd.io docker-ce-rootless-extras \
          cyrus-sasl-plain device-mapper-event  openssl  rpm-build-libs systemd-sysv  lvm2-libs lvm2


  else

    cd "${PKGDIR}" && repotrack docker-ce docker-ce-cli docker-compose-plugin docker-buildx-plugin containerd.io docker-ce-rootless-extras \
            cyrus-sasl-plain device-mapper-event libxml2-python openssl rpm-python rpm-build-libs systemd-sysv systemd-python lvm2-libs lvm2

    yumdownloader --destdir="${PKGDIR}" --resolve \
            docker-ce docker-ce-cli docker-compose-plugin docker-buildx-plugin containerd.io docker-ce-rootless-extras \
            cyrus-sasl-plain device-mapper-event libxml2-python openssl rpm-python rpm-build-libs systemd-sysv systemd-python lvm2-libs lvm2
    
  fi
}


debian() {
  apt update && apt -y install curl

  echo "deb [arch=$(dpkg --print-architecture)] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
  curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | apt-key add -

  apt clean all && rm -rf /var/cache/apt/archives/* && apt autoremove -y

  apt update

  apt-get -y reinstall --download-only docker-ce docker-ce-cli docker-compose-plugin docker-buildx-plugin containerd.io docker-ce-rootless-extras

  cd /var/cache/apt/archives
  for i in $(apt-cache depends docker-ce docker-ce-cli docker-compose-plugin docker-buildx-plugin containerd.io docker-ce-rootless-extras | grep -E 'Depends|Recommends|Suggests' | cut -d ':' -f 2,3 | sed -e s/'<'/''/ -e s/'>'/''/); do apt-get download $i; done

  cd /etc/apt && tar -zcvf "${PKGDIR}"/sources_list.tar.gz sources.list
  cd /etc/apt/sources.list.d && tar -zcvf "${PKGDIR}"/sources_list_d.tar.gz *
  cd /var/lib/apt/lists && tar -zcvf "${PKGDIR}"/sources_list_lib.tar.gz *
  cd /var/cache/apt/archives && tar -zcvf "${PKGDIR}"/sources_softs.tar.gz *

}


mkdir -p "${PKGDIR}"

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

