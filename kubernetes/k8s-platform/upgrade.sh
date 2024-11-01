#!/bin/bash
LANG=zh_CN.UTF-8
UPGRADE_VERSIONS=${UPGRADE_VERSIONS:-"3.5 3.4 3.3"}
REGISTRY_VERSION=$(grep "name: registry$" -A 4 < res/config.yaml | grep version | awk '{print $2}' | sed 's/ //g')
EDITION_TARGET=$(grep "packageEdition" < res/config.yaml | awk '{print $2}' | sed 's/ //g') 

show_usage="args: [--registry --namespace --only-sync-image] "

# TEMP=`getopt -o a --long registry:,replica: -- "$@"`
TEMP=`getopt -o a --long registry:,namespace:,only-sync-image:,target-creds:,target-insecure:,target-plain-http:,skip-sync-image: -- "$@"`
eval set -- "$TEMP"
NAMESPACE="cpaas-system"
ONYL_SYNC_IMAGE="false"
TARGET_CREDS=""
TARGET_INSECURE="false"
TARGET_PLAIN_HTTP="true"
REGISTRY=""
SKIP_SYNC_IMAGE="false"
# whether it is ACP
if kubectl get prdb > /dev/null 2>&1; then
    echo "This is an ACP cluster."
    # verify that the edition match
    EDITION_SOURCE=$(kubectl get prdb -o jsonpath='{.items[0].spec.packageEdition}')
    if ! [[ "$EDITION_SOURCE" == "" && "$EDITION_TARGET" == "Standard" || "$EDITION_SOURCE" == "$EDITION_TARGET" ]];then
        echo "Cluster edition $EDITION_SOURCE does not match packageEdition: $EDITION_TARGET"
        exit 1
    fi
    REGISTRY=$(kubectl get cm -n kube-public global-info -o jsonpath='{.data.registryAddress}')
    # whether registry has auth
    if grep "/etc/kubernetes/registry/auth.yaml" < /etc/kubernetes/manifests/registry.yaml > /dev/null 2>&1; then
        REGISTRY_USERNAME=$(kubectl get secret -n cpaas-system registry-admin -o jsonpath='{.data.username}' | base64 -d)
        REGISTRY_PASSWORD=$(kubectl get secret -n cpaas-system registry-admin -o jsonpath='{.data.password}' | base64 -d)
        TARGET_CREDS=$(echo -n "$REGISTRY_USERNAME:$REGISTRY_PASSWORD" | base64 -w 0)
        TARGET_INSECURE="true"
        TARGET_PLAIN_HTTP="false"
    fi
fi

while true ; do
    case "$1" in
        --registry) REGISTRY=$2; shift 2 ;;
        --namespace) NAMESPACE=$2; shift 2 ;;
        --only-sync-image) ONYL_SYNC_IMAGE=$2; shift 2 ;;
        --target-creds) TARGET_CREDS=$2; shift 2 ;;
        --target-insecure) TARGET_INSECURE=$2; shift 2 ;;
        --target-plain-http) TARGET_PLAIN_HTTP=$2; shift 2 ;;
        --skip-sync-image) SKIP_SYNC_IMAGE=$2; shift 2 ;;
        --) shift; break ;;
        *) echo "Argument error!"; exit 1 ;;
    esac
done

if [[ -z $REGISTRY ]]; then
  echo $show_usage
  exit 0
fi

#set -x
set -e


REGISTRY_IMAGE="ait/registry:$REGISTRY_VERSION"
REGISTRY_OPTIONS="-d --restart=always --name upgrade-registry
-p 1234:5000
-v $(pwd)/registry:/var/lib/registry
-u root:root
"

BASE_OPERATOR_VERSION=$(grep "name: base-operator" -A 4 < res/config.yaml | grep version |awk '{print $2}'|head -1 |  sed 's/ //g')
SYNC_IMAGE_VERSION=$(grep "name: sync-image" -A 4 < res/config.yaml | grep version |awk '{print $2}'|head -1 |  sed 's/ //g')
echo $REGISTRY

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

function start_registry() {
  echo "$(date) 启动临时registry于端口1234"
  get_arch

  docker load -i "res/${ARCH}/registry.tar"
  set +e
  docker rm -f upgrade-registry
  set -e
  docker run $REGISTRY_OPTIONS ${REGISTRY_IMAGE}
  sleep 5
  echo "$(date) registry启动成功"

}

function create_apm_config() {
    echo "$(date) 创建apm相关配置于.apm目录"

    rm -rf .apm
    mkdir .apm
    cp ./res/apmconfig.json .apm/config.json
    sed -i "s/replace-with-real-ip/${REGISTRY}/g" .apm/config.json
    sed -i "s/cpaas-system/${NAMESPACE}/g" .apm/config.json
    sed -i "s/\"INSECURE\"/${TARGET_INSECURE}/g" .apm/config.json
    sed -i "s/\"PLAIN_HTTP\"/${TARGET_PLAIN_HTTP}/g" .apm/config.json
    sed -i "s/\"auth\": \"\"/\"auth\": \"$TARGET_CREDS\"/g" .apm/config.json

    echo "$(date) 创建apm配置成功"
}


function set_sync_image_flag() {
    cat<<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: sync-image-flag
  namespace: kube-public
data:
  version: "$BASE_OPERATOR_VERSION"
EOF
}

function start_sync_image() {
    echo "$(date) 开始同步镜像"

    docker run -ti --net host --privileged -v $(pwd)/.apm/:/root/.apm 127.0.0.1:1234/ait/base-operator-package:${BASE_OPERATOR_VERSION} sync --registry=local,target --target-registry=target --all

    docker run -ti --net host  -v $(pwd)/res:/res  127.0.0.1:1234/ait/sync_image:${SYNC_IMAGE_VERSION} python sync_image.py $REGISTRY "$TARGET_CREDS" $TARGET_INSECURE $TARGET_PLAIN_HTTP

    set_sync_image_flag
    echo "$(date) 同步镜像成功"
}

function start_upgrade_base_operator() {
    echo "$(date) 升级base operator"
    set +e
    kubectl patch apprelease -n cpaas-system base-operator   --type='json' -p='[{"op": "remove", "path": "/spec/values/global/availableVersion"}]' &> /dev/null
    cp /etc/kubernetes/admin.conf $(pwd)/.apm/kubelet.conf
    docker run -ti --net host --privileged -v $(pwd)/.apm/:/root/.apm 127.0.0.1:1234/ait/base-operator-package:${BASE_OPERATOR_VERSION} install --name base-operator --kubeconfig=/root/.apm/kubelet.conf
    sleep 1
    all_num=$(kubectl get apprelease -n $NAMESPACE|wc -l)
    all=$((all_num - 1))
    while true
    do
        ready_num=$(kubectl get apprelease -n $NAMESPACE| grep -w Ready| wc -l)
        ready=$((ready_num))
        echo "$(date) 当前总apprelease: " $all  "当前同步成功apprelease数: " $ready
        if [ $ready -eq $all ]
        then
            echo "$(date) 升级完成。 请登录页面，在产品管理中找到产品->ACP， 点击升级继续后续升级操作。"
            break
        else
            kubectl get apprelease -n $NAMESPACE| grep -vw Ready
            echo "$(date) 升级中，请等待"
            sleep 3
        fi
    done
}

function clean_up() {

    kubectl get apprelease -n $NAMESPACE
    docker rm -f upgrade-registry

}

function upgrade_registry() {
    REGISTRY_POD_NUM=$(kubectl get pods -n kube-system -l component=registry --no-headers -o custom-columns=:metadata.name | wc -l)
    if [ $REGISTRY_POD_NUM == 0 ]; then
        echo "This cluster uses external registry, will skip upgrade registry."
        echo "Registry is ready"
    else
        echo "$(date) 更新镜像仓库"
        bash ./res/upgrade-registry.sh
    fi
}

function check_cluster_modules_status() {
    echo "$(date) 检查集群组件状态"
    set +e
    local clusters=$(kubectl get clustermodules.cluster.alauda.io -o custom-columns=':.metadata.name' | tail -n +2)
    for cls in ${clusters}; do 
        echo "$(date) 检查集群 '${cls}'"
        local version=$(kubectl get clustermodules.cluster.alauda.io "${cls}" -o go-template='{{ .spec.version }}')
        local status=$(kubectl get clustermodules.cluster.alauda.io "${cls}" -o go-template='{{ .status.base.deployStatus }}')
        if [ "${status}" != 'Completed' ]; then
            echo "$(date) 集群 '${cls}' 基础组件的部署状态是 '${status}', 不是 Completed!!!"
            echo "$(date) 中止升级! 请解决问题后重试!"
            exit -1
        fi
        local major_version=$(echo "${version}" | tr '.' ' ' | awk '{print $1}' | tr -d 'v')
        local minor_version=$(echo "${version}" | tr '.' ' ' | awk '{print $2}')
        local upgradable='false'
        for v in ${UPGRADE_VERSIONS}; do
            if [ "${v}" == "${major_version}.${minor_version}" ]; then
                upgradable="true"
                break
            fi
        done
        if [ "${upgradable}" == 'false' ]; then
            if [ "${status}" != 'Completed' ]; then
                echo "$(date) 集群 '${cls}' 组件的当前版本为 '${version}', 不在升级版本支持的范围内: ${UPGRADE_VERSIONS}!!!"
                echo "$(date) 升级中止! 请解决问题后重试!"
                exit -1
            fi
        fi
    done
    echo "$(date) 集群组件状态检查通过"
}


function upgrade() {
    if [ $SKIP_SYNC_IMAGE == 'true' ]; then
        echo "$(date) skip-sync-image=true, Skip sync images."
        set_sync_image_flag
    fi
    CONFIGMAP="kubectl get configmap -n kube-public sync-image-flag -o jsonpath='{.data.version}' 2>/dev/null"
    VERSION=""
    RETURN_CODE=0
    CONFIGMAP_CMD=`eval "$CONFIGMAP"` || RETURN_CODE=$?
    if [ $RETURN_CODE -ne 0 ]; then
        echo "$(date) The first time to sync image."
    else
        VERSION="$CONFIGMAP_CMD"
    fi
    if [ "${ONYL_SYNC_IMAGE}" == 'true' ]; then
        create_apm_config
        start_registry
        start_sync_image
    elif [ "$VERSION" == "$BASE_OPERATOR_VERSION" ]; then
        create_apm_config 
        check_cluster_modules_status
        start_upgrade_base_operator
        clean_up
        upgrade_registry
    else
        create_apm_config
        check_cluster_modules_status
        start_registry
        start_sync_image
        start_upgrade_base_operator
        clean_up
        upgrade_registry
    fi
}

upgrade
