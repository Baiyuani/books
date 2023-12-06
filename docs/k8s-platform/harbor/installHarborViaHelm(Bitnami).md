> 该文档内的域名local.domain可以替换

## 1. 生成证书
```shell
mkdir certs && cd certs/
# 执行完以下3条命令后，当前目录下应该有4个文件
'*.local.domain.crt'  '*.local.domain.csr'  '*.local.domain.key'  '*.local.domain.srl'

#签发证书，10年有效期
openssl req -nodes -subj "/C=CN/ST=Beijing/L=Beijing/CN=*.local.domain" -newkey rsa:2048 -keyout *.local.domain.key -out *.local.domain.csr
openssl x509 -req -days 3650 -in *.local.domain.csr -signkey *.local.domain.key -out *.local.domain.crt
openssl x509 -req -in *.local.domain.csr -CA *.local.domain.crt -CAkey *.local.domain.key -CAcreateserial -out *.local.domain.crt -days 3650 


# 将证书配置docker信任，集群里的所有机器都配置
# The Docker daemon interprets .crt files as CA certificates and .cert files as client certificates.
openssl x509 -inform PEM -in *.local.domain.crt -out *.local.domain.cert
mkdir -p /etc/docker/certs.d/*.local.domain/
cp *.local.domain.cert /etc/docker/certs.d/*.local.domain/
cp *.local.domain.key /etc/docker/certs.d/*.local.domain/
cp *.local.domain.crt /etc/docker/certs.d/*.local.domain/
systemctl daemon-reload
systemctl restart docker


# 将证书添加到可信范围，集群里的所有机器都配置
# centos配置方法
yum install -y ca-certificates
update-ca-trust enable
cp *.local.domain.crt /etc/pki/ca-trust/source/anchors/
update-ca-trust extract
# ubuntu配置方法
cp *.local.domain.crt /usr/local/share/ca-certificates
update-ca-certificates
```


## 2. 配置集群host解析

```bash
kubectl -n kube-system edit cm coredns

#在data部分，添加hosts
apiVersion: v1
data:
  Corefile: |
    .:53 {
        errors
        health {
           lameduck 5s
        }
        ready
        hosts {
           192.168.1.11 harbor.local.domain notary.local.domain
           fallthrough
        }
        kubernetes cluster.local in-addr.arpa ip6.arpa {
           pods insecure
           fallthrough in-addr.arpa ip6.arpa
           ttl 30
        }
        prometheus :9153
        forward . /etc/resolv.conf {
           max_concurrent 1000
        }
        cache 30
        loop
        reload
        loadbalance
    }
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system



vim /etc/hosts  #每台机器都配置

192.168.1.11 harbor.local.domain notary.local.domain
```

## 3. 安装harbor

[Charts参数README](https://github.com/bitnami/charts/tree/master/bitnami/harbor)

```bash
#添加helm repo，创建harbor命名空间
helm repo add bitnami https://charts.bitnami.com/bitnami
kubectl create ns harbor

#创建证书secret，使用第一步中自签的证书
kubectl create secret tls -n harbor local.domain-tls --cert \*.local.domain.crt --key \*.local.domain.key


#部署harbor
helm upgrade --install harbor bitnami/harbor -n harbor  \
--version=11.2.1  \
--set global.storageClass=nfs-client  \
--set harborAdminPassword=1qaz@WSX  \
--set service.type=ingress \
--set ingress.enabled=true \
--set ingress.hosts.core=harbor.local.domain  \
--set externalURL=harbor.local.domain  \
--set service.tls.existingSecret=local.domain-tls  \
--set chartmuseum.enabled=false  \
--set clair.enabled=false  \
--set notary.enabled=false  \
--set trivy.enabled=false  \
--dry-run --debug
#helm upgrade --install harbor bitnami/harbor -n harbor  \
#--version=15.0.0  \
#--set global.storageClass='nfs-client'  \
#--set adminPassword='1qaz@WSX'  \
#--set externalURL='https://harbor.local.domain' \
#--set exposureType='ingress' \
#--set ingress.core.hostname='harbor.local.domain'  \
#--set ingress.notary.hostname='notary.local.domain'  \
#--set persistence.resourcePolicy='' \
#--set persistence.persistentVolumeClaim.registry.size='5Gi' \
#--set persistence.persistentVolumeClaim.jobservice.size='1Gi' \
#--set persistence.persistentVolumeClaim.chartmuseum.size='5Gi' \
#--set persistence.persistentVolumeClaim.trivy.size='5Gi' \
#--set ingress.core.extraTls[0].secretName='local.domain-tls'   \
#--set ingress.core.extraTls[0].hosts[0]='harbor.local.domain'   \
#--set ingress.notary.extraTls[0].secretName='local.domain-tls'   \
#--set ingress.notary.extraTls[0].hosts[0]='notary.local.domain'   \
#--set chartmuseum.enabled='true'  \
#--set notary.enabled='true'  \
#--set trivy.enabled='true'  \
#--dry-run --debug

```

## 4. 使用
跳板机配置host：192.168.1.11 harbor.local.domain ，浏览器访问https://harbor.local.domain ，使用admin/1qaz@WSX登录harbor