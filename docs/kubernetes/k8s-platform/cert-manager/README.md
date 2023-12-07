# 使用helm部署

> [helm安装cert-manager官方文档](https://cert-manager.io/docs/installation/helm/)  \
> [其他参考](https://blog.csdn.net/ai524719755/article/details/116712931)

- 安装

```shell
helm repo add jetstack https://charts.jetstack.io
helm repo update

helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.9.2 \
  --set installCRDs=true \
  --set prometheus.enabled=false \
  --set webhook.timeoutSeconds=10 \
  --set ingressShim.defaultIssuerName=letsencrypt-prod \
  --set ingressShim.defaultIssuerKind=ClusterIssuer \
  --set ingressShim.defaultIssuerGroup=cert-manager.io

# 创建clusterissuer
cat << EOF| kubectl create  -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    email: 13835518617@163.com
    privateKeySecretRef:
      name: letsencrypt-prod
    server: https://acme-v02.api.letsencrypt.org/directory
    solvers:
    - http01:
        ingress:
          class: nginx
EOF
```

- 使用
```shell
#1. 手动创建证书
cat <<EOF >  rancher.site.domain.yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: rancher.site.domain-tls
  namespace: cattle-system
spec:
  secretName: rancher.site.domain-tls
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
  dnsNames:
  - rancher.site.domain
EOF

#2. 配置ingress自动获取证书
    cert-manager.io/cluster-issuer: letsencrypt-prod
    kubernetes.io/tls-acme: "true"
    
  ingressClassName: nginx
  
  
tls:
 - hosts:
   - rancher.site.domain
   secretName: rancher.site.domain-tls
    
    
#证书过期处理
将ingress对应的cert和secret删除
```


## [其他charts](https://github.com/bitnami/charts/tree/master/bitnami/cert-manager)

```shell
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install my-release bitnami/cert-manager
```

