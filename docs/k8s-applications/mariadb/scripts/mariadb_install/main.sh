#!/bin/bash

: "${DEBUG:="false"}"

source configuration.sh



butiecho() {
  case $1 in
  "--green"|-g)
    echo -e "\e[32m$2\e[0m";;
  "--red"|-r)
    echo -e "\e[31m$2\e[0m";;
  "--yellow"|-y)
    echo -e "\e[33m$2\e[0m";;
  "--blue"|-b)
    echo -e "\e[34m$2\e[0m";;
  "--purple"|-p)
    echo -e "\e[35m$2\e[0m";;
  *)
    if [ $# -eq 1 ];then
      echo -e "$1"
    else
      echo -e "$2"
    fi
  esac
}


Init() {
  timedatectl set-timezone Asia/Shanghai
  # 修改内核参数
  if ! grep 'soft nofile 655360' /etc/security/limits.conf &> /dev/null;then
  echo '* soft nofile 655360
* hard nofile 655360
root soft nofile 655360
root hard nofile 655360
* soft nproc 655360
* hard nproc 655360
* soft  memlock  unlimited
* hard memlock  unlimited' >> /etc/security/limits.conf
  echo 'DefaultLimitNOFILE=1024000
DefaultLimitNPROC=1024000' >> /etc/systemd/system.conf
  fi

if cat /etc/redhat-release &> /dev/null;then
  systemctl stop firewalld
  systemctl disable firewalld
  # 添加mariadb源
  echo "# https://mariadb.org/download/
[mariadb]
name = MariaDB
baseurl = https://mirrors.aliyun.com/mariadb/yum/$version/centos7-amd64
gpgkey=https://mirrors.aliyun.com/mariadb/yum/RPM-GPG-KEY-MariaDB
gpgcheck=1
" > /etc/yum.repos.d/MariaDB.repo

  yum makecache
  yum  install MariaDB-server MariaDB-client --enablerepo="mariadb"

elif [ "$(lsb_release -is)" == 'Ubuntu' ];then

  # 关闭自动更新
  sed -i s/1/0/g /etc/apt/apt.conf.d/10periodic || true

  # 关闭防火墙
  ufw disable || true

  # 添加软件源
  OS_RELEASE="$(lsb_release -cs)"
  apt-get -y install apt-transport-https curl
  curl -o /etc/apt/trusted.gpg.d/mariadb_release_signing_key.asc 'https://mariadb.org/mariadb_release_signing_key.asc'
  if ! grep "https://mirrors.aliyun.com/mariadb/repo/$version/ubuntu" /etc/apt/sources.list ;then
    printf "\ndeb [arch=amd64] https://mirrors.aliyun.com/mariadb/repo/%s/ubuntu %s main" "$version" "$OS_RELEASE" >> /etc/apt/sources.list
  fi

  apt -y update
  apt -y install mariadb-server-"$version"
fi

}




# Execution

#Stop execution on any error
#trap "FailTrap" EXIT
set -e
#clear

# Set debug if desired
if [ "${DEBUG}" == "true" ]; then
  set -x
fi

Init