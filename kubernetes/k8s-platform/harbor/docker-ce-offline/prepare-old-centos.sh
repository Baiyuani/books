#!/usr/bin/env bash

# 包来源：https://download.docker.com/linux/centos

# 支持x86_64, aarch64
ARCH='x86_64'
# 支持7/8
OS_VERSION='8'
# 下载目录
WORKDIR='./packages'


wget -P $WORKDIR https://download.docker.com/linux/centos/${OS_VERSION}/${ARCH}/stable/Packages/containerd.io-1.6.22-3.1.el${OS_VERSION}.${ARCH}.rpm
wget -P $WORKDIR https://download.docker.com/linux/centos/${OS_VERSION}/${ARCH}/stable/Packages/docker-ce-24.0.5-1.el${OS_VERSION}.${ARCH}.rpm
wget -P $WORKDIR https://download.docker.com/linux/centos/${OS_VERSION}/${ARCH}/stable/Packages/docker-buildx-plugin-0.11.2-1.el${OS_VERSION}.${ARCH}.rpm
wget -P $WORKDIR https://download.docker.com/linux/centos/${OS_VERSION}/${ARCH}/stable/Packages/docker-ce-cli-24.0.5-1.el${OS_VERSION}.${ARCH}.rpm
wget -P $WORKDIR https://download.docker.com/linux/centos/${OS_VERSION}/${ARCH}/stable/Packages/docker-ce-rootless-extras-24.0.5-1.el${OS_VERSION}.${ARCH}.rpm
wget -P $WORKDIR https://download.docker.com/linux/centos/${OS_VERSION}/${ARCH}/stable/Packages/docker-compose-plugin-2.20.2-1.el${OS_VERSION}.${ARCH}.rpm

case ${OS_VERSION} in
  '8')
    wget -P $WORKDIR http://rpmfind.net/linux/centos/8-stream/BaseOS/${ARCH}/os/Packages/libcgroup-0.41-19.el8.${ARCH}.rpm
    ;;
  '7')
    case ${ARCH} in
      'x86_64') wget -P $WORKDIR http://mirror.centos.org/centos/7/os/x86_64/Packages/libcgroup-0.41-21.el7.x86_64.rpm ;;
      'aarch64') wget -P $WORKDIR http://mirror.centos.org/altarch/7/os/aarch64/Packages/libcgroup-0.41-21.el7.aarch64.rpm ;;
    esac
    ;;
esac
