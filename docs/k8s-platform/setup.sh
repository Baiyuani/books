#! /usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

umask 0022
unset IFS
unset OFS
unset LD_PRELOAD
unset LD_LIBRARY_PATH

export PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'

INSTALLER_VERSION=$(cat res/config.yaml | grep "name: installer" -A 4 | grep version |awk '{print $2}' | sed 's/ //g')
REGISTRY_VERSION=$(cat res/config.yaml | grep "name: registry$" -A 4 | grep version |awk '{print $2}' | sed 's/ //g')
PACKAGE_TYPE=$(cat res/config.yaml | grep packageType | awk '{print $2}')
PACKAGE_EDITION=$(cat res/config.yaml | grep packageEdition | awk '{print $2}')
CPASS_DIR=/cpaas
REGISTRY_IMAGE="ait/registry:$REGISTRY_VERSION"
INSTALLER_PORT=8080
ENABLE_CUSTOMER_DEFINED_PORTS=false
ARCH="x86"
REGISTRY="127.0.0.1:60080"
USERNAME=${USERNAME:-""}
PASSWORD=${PASSWORD:-""}
NETWORK_MODE=ovn

# 命令行示例
# base setup.sh --network-mode calico --enabled-customer-defined-ports
while [[ $# -gt 0 ]]
do
key="$1"
case $key in
    --enabled-customer-defined-ports)   # 启用自定义端口开关
    ENABLE_CUSTOMER_DEFINED_PORTS=true
    shift # remove --enabled-customer-defined-ports
    ;;
    --registry)   # registry url
    REGISTRY="$2"
    shift 2
    ;;
    --username)   # registry username
    USERNAME="$2"
    shift 2
    ;;
    --password)   # registry password
    PASSWORD="$2"
    shift 2
    ;;
    -n|--network-mode)  # 支持ovn、calico、flannel
    NETWORK_MODE="$2"
    shift # past argument
    shift # past value
    ;;
esac
done

INSTALLER_IMAGE="$REGISTRY/ait/cpaas-installer:$INSTALLER_VERSION"
CUSTOM_DIRS=($CPASS_DIR $CPASS_DIR/data $CPASS_DIR/conf $CPASS_DIR/hooks $CPASS_DIR/registry)
for dir in ${CUSTOM_DIRS[@]}
do
  test -d $dir || mkdir $dir
done

# -e NETWORK_MODE 支持参数ovn、calico、flannel
OPTIONS="--name cpaas-installer -d --privileged --net=host --restart=always
-p $INSTALLER_PORT:8080
-v /etc/hosts:/etc/hosts
-v /etc/docker:/etc/docker
-v /root/.docker:/root/.docker
-v /var/run/:/var/run/
-v $CPASS_DIR:$CPASS_DIR
-v $(pwd)/res/:/cpaas/res/
-e INSTALLER_PATH=$(pwd)
-e REGISTRY_FOR_DEPLOY=$REGISTRY
-e NETWORK_MODE=${NETWORK_MODE}
-e ENABLE_CUSTOMER_DEFINED_PORTS=${ENABLE_CUSTOMER_DEFINED_PORTS}
"

REGISTRY_OPTIONS="-d --restart=always -u root --privileged=true --name pkg-registry
-p 60080:5000
-v $(pwd)/registry:/var/lib/registry
"

function get_arch() {
  os_arch=$(uname -m)
  if [[ "$os_arch" =~ "x86" ]]
  then
    ARCH="x86"
  elif [[ "$os_arch" =~ "aarch" ]]
  then
    ARCH="arm64"
  fi
}

function prefight() {
  echo "Step.1 prefight"

  check_root
  check_selinux

  cp res/hooks/* /cpaas/hooks/
  chmod +x /cpaas/hooks/*

  chmod +x res/acp-post-install
  get_arch
}

function command_exists() {
    command -v "$@" > /dev/null 2>&1
}

function check_selinux() {
  if command_exists getenforce
  then
    if ! getenforce | grep -q Disabled
    then
      echo "selinux not disabled"
      exit 1
    fi
    echo "selinux is disabled"
  fi
}

function check_root() {
  if [ "root" != "$(whoami)" ]; then
    echo "only root can execute this script"
    exit 1
  fi
  echo "root: yes"
}

function check_disk() {
  local -r path=$1
  local -r size=$2

  disk_avail=$(df -BG "$path" | tail -1 | awk '{print $4}' | grep -oP '\d+')
  if ((disk_avail < size)); then
    echo "available disk space for $path needs be greater than $size GiB"
    exit 1
  fi

  echo "available disk space($path):  $disk_avail GiB"
}

function ensure_docker() {
  echo "Step.2 ensure docker is ok"

  if ! [ -x "$(command -v docker)" ]; then
    echo "command docker not find"
    install_docker
  fi
  if ! systemctl is-active --quiet docker; then
    echo "docker status is not running"
    install_docker
  fi

  if ! [ -f $CPASS_DIR/data/daemon.json ]; then
    echo "docker daemon.json not exist"
    create_docker_daemon
  fi

  if [ "$USERNAME" != "" ] && [ "$PASSWORD" != "" ]; then
    docker login $REGISTRY -u $USERNAME -p $PASSWORD > /dev/null 2>&1
  fi
}

function create_docker_daemon() {
  cat <<EOF > $CPASS_DIR/data/daemon.json
{
    "insecure-registries": [
        "0.0.0.0/0"
    ],
    "ip-masq": false,
    "iptables": false,
    "log-opts": {
      "max-size": "100m",
      "max-file": "1"
    },
    "live-restore": true,
    "metrics-addr" : "0.0.0.0:9323",
    "experimental" : true,
    "storage-driver": "overlay2"
}
EOF
}

function install_docker() {
  echo "install docker [doing]"

  create_docker_daemon

  tar xvaf "res/${ARCH}/docker.tgz" -C /usr/bin --strip-components=1
  cp -v res/docker.service /etc/systemd/system
  test -d /etc/docker || mkdir -p /etc/docker
  cp -v $CPASS_DIR/data/daemon.json /etc/docker/

  systemctl daemon-reload
  systemctl enable docker

  # because first start docker may be restart some times
  systemctl restart docker || :
  maxSecond=60
  for i in $(seq 1 $maxSecond); do
    if systemctl is-active --quiet docker; then
      break
    fi
    sleep 1
  done
  if ((i == maxSecond)); then
    echo "start docker failed, please check docker service."
    exit 1
  fi
  echo "install docker [ok]"
}

function load_image() {
  if [ "$PACKAGE_TYPE" == "FULL" ]; then
    echo "Step.3 load images [doing]"
    docker load -i res/${ARCH}/registry.tar
    echo "Step.3 load images [ok]"
  else
    echo "Step.3 skip load images"
  fi
}

function install_registry() {
  if [ "$PACKAGE_TYPE" == "FULL" ]; then
    echo "Step.4 install registry [doing]"
    if docker ps | grep -q pkg-registry
    then
      docker restart pkg-registry
    else
      docker run $REGISTRY_OPTIONS ${REGISTRY_IMAGE}
    fi
    echo  "Setp.4 install registry [ok]"
  else
    echo  "Setp.4 skip install registry"
  fi
}

function start_installer() {
  echo "Step.5 start cpaas-installer [doing]"

  docker rm -f cpaas-installer >/dev/null 2>&1 || :
  docker volume prune -f >/dev/null 2>&1 || :

  n=0
  until [ "$n" -ge 5 ]
  do
     docker pull $INSTALLER_IMAGE >/dev/null 2>&1 && break
     printf '.'
     n=$((n+1))
     sleep 3
  done

  docker run $OPTIONS $INSTALLER_IMAGE

  echo "Step.5 start cpaas-installer [ok]"
}

function check_installer() {
  s=10
  for i in $(seq 1 $s)
  do
    echo "Step.6 check cpaas-installer status [doing]"
    url="http://127.0.0.1:$INSTALLER_PORT"
    if ! curl -sSf "$url" >/dev/null; then
      sleep 3
      echo "Step.6 retries left $(($s-$i))"
      continue
    else
      echo "Step.6 check cpaas-installer status [ok]"
      echo "Please use your browser which can connect this machine to open $url for install TKE!"

      ips=$(ip addr | awk '/^[0-9]+: / {}; /inet.*global/ {print gensub(/(.*)\/(.*)/, "\\1", "g", $2)}')
      if [ -n "$ips" ]
      then
        echo "You can also visit the following address:"
        for ip in ${ips[@]}
        do
          echo "http://$ip:$INSTALLER_PORT"
        done
      fi

      exit 0
    fi
  done
  echo "check installer status error"
  docker logs cpaas-installer
  exit 1
}

function install_captain() {
  if [ "$PACKAGE_TYPE" == "FULL" ]; then
    chmod 555 $(pwd)/res/${ARCH}/helm3
    chmod 555 $(pwd)/res/${ARCH}/kubectl-captain
    /bin/cp $(pwd)/res/${ARCH}/kubectl-captain /usr/local/bin/
  fi
}

prefight
ensure_docker
install_captain
load_image
install_registry
start_installer
check_installer
