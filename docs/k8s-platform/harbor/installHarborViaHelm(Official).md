
> https://github.com/goharbor/harbor-helm

## 1.[生成证书](https://goharbor.io/docs/2.5.0/install-config/configure-https/)
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

- 安装
```shell
helm repo add harbor https://helm.goharbor.io
helm fetch harbor/harbor --untar
kubectl create ns harbor

kubectl create secret tls -n harbor local.domain-tls --cert \*.local.domain.crt --key \*.local.domain.key

helm upgrade --install harbor --namespace harbor harbor/harbor \
  --version=1.10.1 \
  --set expose.tls.certSource='secret' \
  --set expose.tls.secret.secretName='local.domain-tls' \
  --set expose.tls.secret.notarySecretName='local.domain-tls' \
  --set expose.ingress.hosts.core='harbor.local.domain' \
  --set expose.ingress.hosts.notary='notary.local.domain' \
  --set-string expose.ingress.annotations.'nginx\.org/client-max-body-size'="1024m" \
  --set persistence.persistentVolumeClaim.registry.storageClass=nfs-client \
  --set persistence.persistentVolumeClaim.registry.size='500G' \
  --set persistence.persistentVolumeClaim.registry.accessMode='ReadWriteMany' \
  --set persistence.persistentVolumeClaim.chartmuseum.storageClass=nfs-client \
  --set persistence.persistentVolumeClaim.chartmuseum.size='100G' \
  --set persistence.persistentVolumeClaim.chartmuseum.accessMode='ReadWriteMany' \
  --set persistence.persistentVolumeClaim.jobservice.jobLog.storageClass=nfs-client \
  --set persistence.persistentVolumeClaim.jobservice.jobLog.size='20G' \
  --set persistence.persistentVolumeClaim.jobservice.jobLog.accessMode='ReadWriteMany' \
  --set persistence.persistentVolumeClaim.jobservice.scanDataExports.storageClass=nfs-client \
  --set persistence.persistentVolumeClaim.jobservice.scanDataExports.size='20G' \
  --set persistence.persistentVolumeClaim.jobservice.scanDataExports.accessMode='ReadWriteMany' \
  --set persistence.persistentVolumeClaim.database.storageClass=nfs-client \
  --set persistence.persistentVolumeClaim.database.size='500G' \
  --set persistence.persistentVolumeClaim.redis.storageClass=nfs-client \
  --set persistence.persistentVolumeClaim.redis.size='20G' \
  --set persistence.persistentVolumeClaim.trivy.storageClass=nfs-client \
  --set persistence.persistentVolumeClaim.trivy.size='500G' \
  --set externalURL=https://harbor.local.domain \
  --set harborAdminPassword='Harbor12345'
  
  
# 其他
  --set-string expose.ingress.harbor.annotations.'cert-manager\.io/cluster-issuer'='cluster-issuer' \
  --set-string expose.ingress.harbor.annotations.'kubernetes\.io/tls-acme'="true" \
  --set-string expose.ingress.notary.annotations.'cert-manager\.io/cluster-issuer'='cluster-issuer' \
  --set-string expose.ingress.notary.annotations.'kubernetes\.io/tls-acme'="true" \
```
