# v1.10版本，测试失败 

## https://rook.io/docs/rook/v1.10/Helm-Charts/operator-chart/#installing


## install operator
```shell
helm repo add rook-release https://charts.rook.io/release
helm upgrade --install --create-namespace --namespace rook-ceph rook-ceph rook-release/rook-ceph -f values.yaml

Important Notes:
- You must customize the 'CephCluster' resource in the sample manifests for your cluster.
- Each CephCluster must be deployed to its own namespace, the samples use `rook-ceph` for the namespace.
- The sample manifests assume you also installed the rook-ceph operator in the `rook-ceph` namespace.
- The helm chart includes all the RBAC required to create a CephCluster CRD in the same namespace.
- Any disk devices you add to the cluster in the 'CephCluster' must be empty (no filesystem and no partitions).

```


## insstall ceph cluster

```shell
helm repo add rook-release https://charts.rook.io/release
ku -f values-override.yaml


Important Notes:
- You can only deploy a single cluster per namespace
- If you wish to delete this cluster and start fresh, you will also have to wipe the OSD disks using `sfdisk`

```


```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: rook-ceph
  namespace: rook-ceph
  annotations:
#    kubernetes.io/ingress.class: nginx  # ingress类，或者存在default ingressclass时不需要指定
#    kubernetes.io/tls-acme: "true" #Get Automatic HTTPS with Let's Encrypt and Kubernetes Ingress
#    cert-manager.io/issuer: gitlab-issuer
#    cert-manager.io/cluster-issuer: cluster-issuer
    nginx.ingress.kubernetes.io/affinity: cookie   # 启用会话保持
#    nginx.ingress.kubernetes.io/app-root: /web   #访问域名根时，默认跳转的服务
    nginx.ingress.kubernetes.io/proxy-buffer-size: 512k
    nginx.ingress.kubernetes.io/proxy-buffering: "on"
    nginx.ingress.kubernetes.io/proxy-buffers-number: "4"
    nginx.ingress.kubernetes.io/proxy-connect-timeout: "720"
    nginx.ingress.kubernetes.io/proxy-max-temp-file-size: 1024m
    nginx.ingress.kubernetes.io/proxy-read-timeout: "600"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "600"
    nginx.ingress.kubernetes.io/send-timeout: "600"
    nginx.ingress.kubernetes.io/proxy-body-size: 100M   # 请求包大小限制
    nginx.ingress.kubernetes.io/ssl-redirect: "true"   # 强制跳转https
    nginx.ingress.kubernetes.io/use-regex: "true"    # 允许正则
    nginx.ingress.kubernetes.io/configuration-snippet: |     # nginx配置
      rewrite  ^/web1/(.*)  /web/$1 last;
#      proxy_set_header  X-Forwarded-Proto   https;
#      rewrite  ^/file(.*) /FileAPI2/v1/file$1 last;
#      rewrite  ^/sso/apis(.*) /apis/apis$1 last;
#      rewrite  /sso/bootstrap  /apis/bootstrap last;
#      rewrite  /ExportAPI/api/Export/(.*)  /api/export/$1 last;
#      rewrite  /ExportAPI/api/excelExport/(.*)  /api/excelExport/$1 last;
spec:
#  tls:   # https证书配置
#    - hosts:
#        - ceph.local.domain
#      secretName: ingress-secret   # 证书secret
  ingressClassName: nginx
  rules:
  - host: ceph.local.domain
    http:
      paths:
      - backend:
          service:
            name: rook-ceph-mgr-dashboard
            port:
              number: 8443
        path: /
        pathType: ImplementationSpecific  




apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ceph-ingress
  namespace: rook-ceph
spec:
  ingressClassName: nginx
  rules:
  - host: ceph.local.domain
    http:
      paths:
      - backend:
          service:
            name: rook-ceph-mgr-dashboard
            port:
              number: 8443
        path: /
        pathType: ImplementationSpecific  

```




## 擦除磁盘

```shell
DISK="/dev/vdb"

# Zap the disk to a fresh, usable state (zap-all is important, b/c MBR has to be clean)
sgdisk --zap-all $DISK

# Wipe a large portion of the beginning of the disk to remove more LVM metadata that may be present
dd if=/dev/zero of="$DISK" bs=1M count=100 oflag=direct,dsync

# SSDs may be better cleaned with blkdiscard instead of dd
blkdiscard $DISK

# Inform the OS of partition table changes
partprobe $DISK
```