# docker安装harbor

## harbor
> 更新日期：20230904 \
> 版本：v2.7.2
> 文档来源：https://goharbor.io/docs/2.7.0/install-config/


### 1.环境准备
> https://goharbor.io/docs/2.7.0/install-config/installation-prereqs/

需提前安装好docker，离线安装可参考[docker-ce-offline](./docker-ce-offline/readme.md)

### 2.[下载安装包](https://github.com/goharbor/harbor/releases/tag/v2.7.2)，可选离线或在线

https://github.com/goharbor/harbor/releases/download/v2.7.2/harbor-offline-installer-v2.7.2.tgz


```shell
# 解压
tar xzvf harbor-offline-installer-v2.7.2.tgz
```


- [生成证书](https://goharbor.io/docs/2.5.0/install-config/configure-https/)，如果不需要https则跳过

```shell
mkdir -p /data/certs && cd /data/certs

openssl genrsa -out ca.key 4096

openssl req -x509 -new -nodes -sha512 -days 3650 \
 -subj "/C=CN/ST=Beijing/L=Beijing/O=example/OU=Personal/CN=harbor.local.domain" \
 -key ca.key \
 -out ca.crt
 
openssl genrsa -out harbor.local.domain.key 4096

openssl req -sha512 -new \
    -subj "/C=CN/ST=Beijing/L=Beijing/O=example/OU=Personal/CN=harbor.local.domain" \
    -key harbor.local.domain.key \
    -out harbor.local.domain.csr
    
cat > v3.ext <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1=harbor.local.domain
DNS.2=yourdomain
DNS.3=hostname
EOF

openssl x509 -req -sha512 -days 3650 \
    -extfile v3.ext \
    -CA ca.crt -CAkey ca.key -CAcreateserial \
    -in harbor.local.domain.csr \
    -out harbor.local.domain.crt
    
# 证书docker配置，集群里的所有机器都配置
#cp harbor.local.domain.crt /data/certs/
#cp harbor.local.domain.key /data/certs/
openssl x509 -inform PEM -in harbor.local.domain.crt -out harbor.local.domain.cert
mkdir -p /etc/docker/certs.d/harbor.local.domain/
cp harbor.local.domain.cert /etc/docker/certs.d/harbor.local.domain/
cp harbor.local.domain.key /etc/docker/certs.d/harbor.local.domain/
cp ca.crt /etc/docker/certs.d/harbor.local.domain/

systemctl daemon-reload
systemctl restart docker

# 将证书添加到可信范围，集群里的所有机器都配置
# centos配置方法
yum install -y ca-certificates
update-ca-trust enable
cp harbor.local.domain.crt /etc/pki/ca-trust/source/anchors/
update-ca-trust extract
# ubuntu配置方法
cp harbor.local.domain.crt /usr/local/share/ca-certificates
update-ca-certificates

```

### 2.install

**修改配置文件harbor.yml**

- 设置hostname
- 根据实际需要删除`https`段
- 修改平台管理员密码`harbor_admin_password`，修改db密码`database.password`
- 修改数据存储目录`data_volume`


```shell
cd harbor/ && cp harbor.yml.tmpl harbor.yml
vim harbor.yml
```


**安装**

```shell
./install.sh --with-chartmuseum

# 可选组件 
./install.sh --with-notary --with-trivy --with-chartmuseum
```

- [生命周期管理](https://goharbor.io/docs/2.5.0/install-config/reconfigure-manage-lifecycle/)


### 3.使用
#TODO::待补充
```shell
#访问https://harbor.local.domain ,创建项目baiyuani，手动推送镜像harbor.local.domain/baiyuani/demo:0.1.4
#创建密钥
kubectl create secret docker-registry harbor-registry -n default \
--docker-username=admin \
--docker-password=qweasd123 \
--docker-server=harbor.local.domain  \
--dry-run=client -o yaml | kubectl apply -f -
#测试安装服务
helm upgrade --install demo ./demo -n default \
--set image.repository='harbor.local.domain/baiyuani/demo' \
--set image.imagePullSecrets[0]='harbor-registry'
```



### 4. 补充：containerd配置

```shell
#以前使用 docker-engine 的时候，只需要修改/etc/docker/daemon.json 就行，但是新版的 k8s 已经使用 containerd 了，所以这里需要做相关配置，要不然 containerd 会失败。证书（ca.crt）可以在页面上下载：

mkdir /etc/containerd/harbor.local.domain
cp ca.crt /etc/containerd/harbor.local.domain/


vim /etc/containerd/config.toml
[plugins."io.containerd.grpc.v1.cri".registry]
      config_path = ""

      [plugins."io.containerd.grpc.v1.cri".registry.auths]

      [plugins."io.containerd.grpc.v1.cri".registry.configs]
        [plugins."io.containerd.grpc.v1.cri".registry.configs."harbor.local.domain".tls]
          ca_file = "/etc/containerd/harbor.local.domain/ca.crt"
        [plugins."io.containerd.grpc.v1.cri".registry.configs."harbor.local.domain".auth]
          username = "admin"
          password = "Harbor12345"

      [plugins."io.containerd.grpc.v1.cri".registry.headers]

      [plugins."io.containerd.grpc.v1.cri".registry.mirrors]
        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."harbor.local.domain"]
          endpoint = ["https://harbor.local.domain"]
          
          
#重新加载配置
systemctl daemon-reload
#重启containerd
systemctl restart containerd

cat <<EOF > /etc/crictl.yaml
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 10
debug: false
EOF


crictl pull harbor.local.domain/bigdata/mysql:5.7.38
```