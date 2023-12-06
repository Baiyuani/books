## 安装gitlab

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
  --set global.hosts.domain=baiyuani.top \
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



## 阿里gitlab

glpat-XXNCMNyeLpstBBFFWGmu



## 阿里服务器资料(旧)

```
192.168.0.204
k8s-master1


gitlab admin:
root
KJFW95W3NNLsspjfdX5XxGGzJ4J2swv2rw49RhjZpvSiomLvP2OqaFgey5Qrpn10

token:
q_z_AocFFEqjAT3f6drK


kubectl create secret docker-registry reg-baiyuani  \
--docker-username=tracy \
--docker-password=q_z_AocFFEqjAT3f6drK \
--docker-server=registry.baiyuani.top  \
--dry-run=client -o yaml | kubectl apply -f -


root@k8s-master1:~/Coding/helm/charts# helm ls -A
NAME      	NAMESPACE             	REVISION	UPDATED                                	STATUS         CHART                                 	APP VERSION
demo      	default               	1       	2022-08-14 14:11:28.88351583 +0800 CST 	deployed       demo-0.1.4                            	0.1.4      
gitlab    	default               	1       	2022-08-14 11:24:44.616276249 +0800 CST	deployed       gitlab-6.2.2                          	15.2.2     
local     	gitlab-agent          	1       	2022-08-14 14:37:32.85677801 +0800 CST 	deployed       gitlab-agent-1.4.0                    	v15.3.0    
nfs-client	nfs-client-provisioner	1       	2022-08-14 10:02:00.008536971 +0800 CST	deployed       nfs-subdir-external-provisioner-4.0.17	4.0.2 
```



新token  glpat-32Do-kNJCxss9M141RhE