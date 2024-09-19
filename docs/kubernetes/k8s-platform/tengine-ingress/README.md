# Tengine-Ingress

## 安装

- 直接使用 Tengine-Ingress 提供的镜像，镜像基于Anolis OS和Alpine OS ，支持 AMD64 和 ARM64 架构。

```shell
docker pull tengine-ingress-registry.cn-hangzhou.cr.aliyuncs.com/tengine/tengine-ingress:1.1.0
docker pull tengine-ingress-registry.cn-hangzhou.cr.aliyuncs.com/tengine/tengine-ingress:1.1.0-alpine
```

- [install.yaml](install.yaml)

```shell
kubectl apply -f install.yaml
```
