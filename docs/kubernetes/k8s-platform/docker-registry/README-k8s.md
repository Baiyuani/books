# registry in k8s

> https://docs.docker.com/registry/
>
> 部署文档：
> https://distribution.github.io/distribution/about/deploying/


## 1. 自签名证书
```bash
mkdir -p certs

openssl req \
  -newkey rsa:4096 -nodes -sha256 -keyout certs/domain.key \
  -addext "subjectAltName = DNS:myregistry.domain.com" \
  -x509 -days 36500 -out certs/domain.crt

```

## 2. 创建密码文件

```shell
mkdir -p auth

docker run \
  --entrypoint htpasswd \
  httpd:2 -Bbn testuser testpassword > auth/htpasswd
```


## 3.安装registry
```shell
kubectl create secret tls docker-registry-tls -n docker-registry \
--cert certs/domain.crt \
--key certs/domain.key

kubectl create secret generic docker-registry-auth -n docker-registry \
--from-file=auth/htpasswd

kubectl apply -f docker-registry.yaml
```

