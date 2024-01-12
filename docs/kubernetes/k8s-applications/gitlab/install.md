---
tags:
  - gitlab
---

# 安装gitlab

## 使用docker镜像安装（所有组件运行在一个pod里）

[gitlab-ce-single.yaml](manifests/gitlab-ce-single.yaml)

```shell
kubectl label node <nodeName> node-role.kubernetes.io/critical-apps=gitlab
kubectl taint nodes <node-name> node-role.kubernetes.io/critical-apps=gitlab:NoSchedule

kubectl create ns gitlab
kubectl -n gitlab create -f gitlab-ce-single.yaml
```

- 配置文件位于`/etc/gitlab/gitlab.rb`，修改配置文件后重启pod

```config
# 部署后首要配置，gitlab的访问地址
external_url 'https://gitlab.local.site'

# 认证对接配置
gitlab_rails['omniauth_enabled'] = true
gitlab_rails['omniauth_block_auto_created_users'] = false
gitlab_rails['omniauth_allow_single_sign_on'] = [ 'oauth2_generic']
gitlab_rails['omniauth_external_providers'] = ['oauth2_generic','openid_connect']
gitlab_rails['omniauth_providers'] = [
 {
   "name" => "oauth2_generic",
   "label" => "Login with xxxxx",
   "app_id" => "xxxxxxxxxxxxxxxxxxxxxx",
   "app_secret" => "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
   "args" => {
     client_options: {
         'site' => 'https://oatuh.site',
         'user_info_url' => 'https://oatuh.site/sso/apis/v2/me/profile',
         'authorize_url': 'https://oatuh.site/sso/oauth2/authorize?scope=profile', 
         'token_url': 'https://oatuh.site/sso/oauth2/token?scope=profile' 
       },
     "user_response_structure": {
        "root_path": [], # i.e. if attributes are returned in JsonAPI format (in a 'user' node nested under a 'data' node)
         "id_path": [ "entities", 0, "account"],
         "attributes": { } # if the nickname attribute of a user is called 'username'
       } 
     }
   }
 ]

# 镜像库registry服务器启用
registry_external_url 'http://registry.local.site'
registry['enable'] = true
registry['registry_http_addr'] = "0.0.0.0:5000"

# gitlab设置启用镜像库。host和port填镜像库显示在gitlab上的地址
gitlab_rails['registry_enabled'] = true
gitlab_rails['registry_host'] = "registry.local.site"
#gitlab_rails['registry_port'] = "80"
gitlab_rails['registry_path'] = "/var/opt/gitlab/gitlab-rails/shared/registry"
#registry['token_realm'] = "https://git.ketanyun.cn"


nginx['enable'] = true
nginx['client_max_body_size'] = '2048m'
#nginx['redirect_http_to_https'] = true
#nginx['redirect_http_to_https_port'] = 80
#nginx['ssl_certificate'] = "/etc/gitlab/ssl/git.ketanyun.cn.crt"
#nginx['ssl_certificate_key'] = "/etc/gitlab/ssl/git.ketanyun.cn.key"
```

## 使用helm安装

!!! note

    所有组件都需要运行 Kubernetes 1.20 或更高版本的集群才能工作

[官方charts文档](https://docs.gitlab.com/charts/charts/)

[安装文档](https://docs.gitlab.com/charts/installation/deployment.html)

```shell
#设置默认的storageClass
kubectl patch storageclass nfs-client -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

# appVersion: v16.7.0
# certmanager和ingress最好单独装
helm repo add gitlab https://charts.gitlab.io/
helm repo update
helm upgrade --install gitlab gitlab/gitlab -n gitlab --create-namespace \
  --timeout 900s \
  --set global.hosts.domain=example.com \
  --set global.hosts.externalIP=10.10.10.10 \
  --set certmanager-issuer.email=me@example.com \
  --set postgresql.image.tag=13.6.0 \
  --version=7.7.0 \
  --set certmanager.install=false \
  --set nginx-ingress.enabled=false \
  --set prometheus.install=false \
  --set postgresql.persistence.size='1Ti' \
  --set minio.persistence.size='1Ti' \
  --set redis.master.persistence.size='50Gi' \
  --set gitlab.gitaly.persistence.size='1Ti' \
  --set global.edition=ce  # 默认部署ee企业版，ce需要明确指定
  
# 部署之后，需要修改gitlab的4个ingress的ingressClass。charts目前没有参数可配置
```

```shell
kubectl get secret <name>-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode ; echo
```


## 问题记录
ingress开启hostport，需要绑定主机的22端口，所以需要提前将主机的ssh服务端口修改一个


