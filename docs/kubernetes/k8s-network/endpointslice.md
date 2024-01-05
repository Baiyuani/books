---
tags:
  - network
  - k8s
---
# [EndpointSlice](https://kubernetes.io/zh-cn/docs/concepts/services-networking/endpoint-slices/)

https://kubernetes.io/zh-cn/docs/concepts/services-networking/service/#endpointslices

https://blog.csdn.net/junbaozi/article/details/127857965

> Kubernetes v1.21 [stable]

- 旧版endpoints api最多只能将流量发送到 1000 个可用的支撑端点。
- 从1.19版本开始，kube-proxy默认已经使用endpointslice。
- 定制创建的endpoint，默认会镜像到endpointslice

