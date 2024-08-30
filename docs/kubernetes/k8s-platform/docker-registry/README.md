# registry

> https://docs.docker.com/registry/
>
> 部署文档：
> https://distribution.github.io/distribution/about/deploying/


## 1. 自签名证书
```bash
mkdir certs && cd certs/
# 执行完以下3条命令后，当前目录下应该有4个文件
'*.dachui.com.crt'  '*.dachui.com.csr'  '*.dachui.com.key'  '*.dachui.com.srl'

#签发证书，10年有效期
openssl req -nodes -subj "/C=CN/ST=Beijing/L=Beijing/CN=*.dachui.com" -newkey rsa:2048 -keyout *.dachui.com.key -out *.dachui.com.csr
openssl x509 -req -days 3650 -in *.dachui.com.csr -signkey *.dachui.com.key -out *.dachui.com.crt
openssl x509 -req -in *.dachui.com.csr -CA *.dachui.com.crt -CAkey *.dachui.com.key -CAcreateserial -out *.dachui.com.crt -days 3650 


# 将证书添加到可信范围，集群里的所有机器都配置
# centos配置方法
yum install -y ca-certificates
update-ca-trust enable
cp *.dachui.com.crt /etc/pki/ca-trust/source/anchors/
update-ca-trust extract
# ubuntu配置方法
cp *.dachui.com.crt /usr/local/share/ca-certificates
update-ca-certificates

```


## 2.安装registry
```shell
mkdir -p /data/registry && cd ..

docker run -d \
  -p 5000:5000 \
  --restart=always \
  --name registry \
  -v /data/registry:/var/lib/registry \
  registry:2

docker run -d \
  -p 443:443 \
  --restart=always \
  --name registry \
  -v /data/registry:/var/lib/registry \
  -v "$(pwd)"/certs:/certs \
  -e REGISTRY_HTTP_ADDR=0.0.0.0:443 \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/'*.dachui.com.crt' \
  -e REGISTRY_HTTP_TLS_KEY=/certs/'*.dachui.com.key' \
  registry:2
  
#限制cpu和内存  --cpus 2  -m 4096m \
```


## 3.验证
```shell
#配置hosts解析
vim /etc/hosts 
192.168.1.11 reg.dachui.com

#推送镜像
docker tag xxx reg.dachui.com/test/pause:3.5
docker push reg.dachui.com/test/pause:3.5
# 问题记录
# 1.Get https://reg.dachui.com/v2/: x509: certificate signed by unknown authority
# 2.Error response from daemon: Missing client certificate *.dachui.com.cert for key *.dachui.com.key
# 解决方案:
mkdir -p /etc/docker/certs.d/reg.dachui.com/
cp ./certs/reg.dachui.com.crt /etc/docker/certs.d/reg.dachui.com/reg.dachui.com.cert
systemctl daemon-reload
systemctl restart docker


#查看仓库里已有的镜像
curl https://reg.dachui.com/v2/_catalog
{"repositories":["test/pause"]}

#查看镜像tag  e.g: curl https://reg.dachui.com/v2/{镜像名称}/tags/list
curl https://reg.dachui.com/v2/test/pause/tags/list
{"name":"test/pause","tags":["3.5"]}
```


## 4.启用身份认证
Warning: You cannot use authentication with authentication schemes that send credentials as clear text. You must configure TLS first for authentication to work.


Create a password file with one entry for the user testuser, with password testpassword:
```shell
mkdir auth
docker run \
 --entrypoint htpasswd \
 httpd:2 -Bbn testuser testpassword > auth/htpasswd
```


Restart the registry with basic authentication.
```shell
docker run -d \
  -p 443:443 \
  --restart=always \
  --name registry \
  -v /data/registry:/var/lib/registry \
  -v "$(pwd)"/certs:/certs \
  -e REGISTRY_HTTP_ADDR=0.0.0.0:443 \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/'*.dachui.com.crt' \
  -e REGISTRY_HTTP_TLS_KEY=/certs/'*.dachui.com.key' \
  -v "$(pwd)"/auth:/auth \
  -e "REGISTRY_AUTH=htpasswd" \
  -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
  -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
  registry:2
  
```
Try to pull an image from the registry, or push an image to the registry. These commands fail.

Log in to the registry.
```shell
 docker login reg.dachui.com
```

Provide the username and password from the first step.

Test that you can now pull an image from the registry or push an image to the registry.

## 5. 使用systemd 管理registry


`vim /lib/systemd/system/registry.socket`

```ini
[Unit]
Description=Distribution registry

[Socket]
ListenStream=5000

[Install]
WantedBy=sockets.target
```

`vim /lib/systemd/system/registry.service`

```ini
[Unit]
Description=Distribution registry
After=docker.service
Requires=docker.service

[Service]
#TimeoutStartSec=0
Restart=always
ExecStartPre=-/usr/bin/docker stop %N
ExecStartPre=-/usr/bin/docker rm %N
ExecStart=/usr/bin/docker run --name %N \
    -v /data/registry:/var/lib/registry \
    -p 5000:5000 \
    registry:2

[Install]
WantedBy=multi-user.target
```

## 6. 常用命令

```shell
# 列出所有镜像
curl -qsS localhost:5000/v2/_catalog | python3 -m json.tool

# 列出镜像的所有tag
curl -qsS localhost:5000/v2/kubernetes/pause/tags/list | python3 -m json.tool

# docker registry cli 列出所有镜像和tag
docker run --rm anoxis/registry-cli -r http://192.168.182.21:5000

# 当registry也在本地docker时，可以直接链接到registry容器
docker run --rm --link registry anoxis/registry-cli -r http://registry:5000
```

## 7. docker registry ui   

https://github.com/Joxit/docker-registry-ui


```shell
mkdir docker-registry-ui
cd docker-registry-ui
vim docker-compose.yml
docker compose up -d
```

```yaml
version: '3.8'

services:
  registry-ui:
    image: joxit/docker-registry-ui:main
    restart: always
    ports:
      - 80:80
    environment:
      - SINGLE_REGISTRY=true
      - REGISTRY_TITLE=Docker Registry UI
      - DELETE_IMAGES=true
      - SHOW_CONTENT_DIGEST=true
      - NGINX_PROXY_PASS_URL=http://registry-server:5000
      - SHOW_CATALOG_NB_TAGS=true
      - CATALOG_MIN_BRANCHES=1
      - CATALOG_MAX_BRANCHES=1
      - TAGLIST_PAGE_SIZE=100
      - REGISTRY_SECURED=false
      - CATALOG_ELEMENTS_LIMIT=1000
    container_name: registry-ui
```


