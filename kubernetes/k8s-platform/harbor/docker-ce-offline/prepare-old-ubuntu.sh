#!/usr/bin/env bash

# 包来源：https://download.docker.com/linux/ubuntu/dists/

# 支持amd64, armhf, arm64, or s390x
ARCH='amd64'
# 支持20.04(focal) 22.04(jammy)
OS_VERSION='focal'
# 下载目录
WORKDIR='./packages'

case $OS_VERSION in
  'focal') OS_SEM_VERSION='20.04';;
  'jammy') OS_SEM_VERSION='22.04';;
  *) echo '未知版本' ; exit 1 ;;
esac


wget -P $WORKDIR https://download.docker.com/linux/ubuntu/dists/${OS_VERSION}/pool/stable/${ARCH}/containerd.io_1.6.22-1_${ARCH}.deb
wget -P $WORKDIR https://download.docker.com/linux/ubuntu/dists/${OS_VERSION}/pool/stable/${ARCH}/docker-buildx-plugin_0.11.2-1~ubuntu.${OS_SEM_VERSION}~${OS_VERSION}_${ARCH}.deb
wget -P $WORKDIR https://download.docker.com/linux/ubuntu/dists/${OS_VERSION}/pool/stable/${ARCH}/docker-ce-cli_24.0.5-1~ubuntu.${OS_SEM_VERSION}~${OS_VERSION}_${ARCH}.deb
wget -P $WORKDIR https://download.docker.com/linux/ubuntu/dists/${OS_VERSION}/pool/stable/${ARCH}/docker-ce-rootless-extras_24.0.5-1~ubuntu.${OS_SEM_VERSION}~${OS_VERSION}_${ARCH}.deb
wget -P $WORKDIR https://download.docker.com/linux/ubuntu/dists/${OS_VERSION}/pool/stable/${ARCH}/docker-ce_24.0.5-1~ubuntu.${OS_SEM_VERSION}~${OS_VERSION}_${ARCH}.deb
wget -P $WORKDIR https://download.docker.com/linux/ubuntu/dists/${OS_VERSION}/pool/stable/${ARCH}/docker-compose-plugin_2.20.2-1~ubuntu.${OS_SEM_VERSION}~${OS_VERSION}_${ARCH}.deb


