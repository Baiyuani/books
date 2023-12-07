# 安装gitlab



[官方charts文档](https://docs.gitlab.com/charts/charts/)
[安装文档](https://docs.gitlab.com/charts/installation/deployment.html)

```shell
#设置默认的storageClass
kubectl patch storageclass nfs-client -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'


# certmanager和ingress最好单独装
helm repo add gitlab https://charts.gitlab.io/
helm repo update
helm upgrade --install gitlab gitlab/gitlab -n gitlab --create-namespace \
  --timeout 900s \
  --set global.hosts.domain=site.domain \
  --set global.hosts.externalIP=8.210.43.192 \
  --set certmanager-issuer.email=13835518617@163.com \
  --set postgresql.image.tag=13.6.0 \
  --version=6.5.1 \
  --set certmanager.install=false \
  --set nginx-ingress.enabled=false \
  --set prometheus.install=false \
  --set postgresql.persistence.size='1Ti' \
  --set minio.persistence.size='1Ti' \
  --set redis.master.persistence.size='50Gi' \
  --set gitlab.gitaly.persistence.size='1Ti' 

# 部署之后，需要修改gitlab的4个ingress的ingressClass。charts目前没有参数可配置
```

## 问题记录
ingress开启hostport，需要绑定主机的22端口，所以需要提前将主机的ssh服务端口修改一个


