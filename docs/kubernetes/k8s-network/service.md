---
tags:
  - network
  - k8s
---


## [service流量策略](https://kubernetes.io/zh-cn/docs/reference/networking/virtual-ips/#traffic-policies)

> 你可以设置 .spec.internalTrafficPolicy 和 .spec.externalTrafficPolicy 字段来控制 Kubernetes 如何将流量路由到健康（“就绪”）的后端。

### 内部流量策略

> 特性状态： Kubernetes v1.26 [stable]

你可以设置 .spec.internalTrafficPolicy 字段来控制来自内部源的流量如何被路由。 有效值为 Cluster 和 Local。 将字段设置为 Cluster 会将内部流量路由到所有准备就绪的端点， 将字段设置为 Local 仅会将流量路由到本地节点准备就绪的端点。 如果流量策略为 Local 但没有本地节点端点，那么 kube-proxy 会丢弃该流量。

### 外部流量策略

你可以设置 .spec.externalTrafficPolicy 字段来控制从外部源路由的流量。 有效值为 Cluster 和 Local。 将字段设置为 Cluster 会将外部流量路由到所有准备就绪的端点， 将字段设置为 Local 仅会将流量路由到本地节点上准备就绪的端点。 如果流量策略为 Local 并且没有本地节点端点， 那么 kube-proxy 不会转发与相关 Service 相关的任何流量。

### 流向正终止的端点的流量

> 特性状态： Kubernetes v1.28 [stable]

如果为 kube-proxy 启用了 ProxyTerminatingEndpoints 特性门控且流量策略为 Local， 则节点的 kube-proxy 将使用更复杂的算法为 Service 选择端点。 启用此特性时，kube-proxy 会检查节点是否具有本地端点以及是否所有本地端点都标记为正在终止过程中。 如果有本地端点并且所有本地端点都被标记为处于终止过程中， 则 kube-proxy 会将转发流量到这些正在终止过程中的端点。 否则，kube-proxy 会始终选择将流量转发到并未处于终止过程中的端点。

这种对处于终止过程中的端点的转发行为使得 NodePort 和 LoadBalancer Service 能有条不紊地腾空设置了 externalTrafficPolicy: Local 时的连接。

当一个 Deployment 被滚动更新时，处于负载均衡器后端的节点可能会将该 Deployment 的 N 个副本缩减到 0 个副本。在某些情况下，外部负载均衡器可能在两次执行健康检查探针之间将流量发送到具有 0 个副本的节点。 将流量路由到处于终止过程中的端点可确保正在缩减 Pod 的节点能够正常接收流量， 并逐渐降低指向那些处于终止过程中的 Pod 的流量。 到 Pod 完成终止时，外部负载均衡器应该已经发现节点的健康检查失败并从后端池中完全移除该节点。

## 内核参数 net.bridge.bridge-nf-call-iptables = 1 的作用

首先 Kubernetes 的 Service 本质是个反向代理，访问 Service 时会进行 DNAT，将原本访问 ClusterIP:Port 的数据包 NAT 成 Service 的某个 Endpoint (PodIP:Port)，
然后内核将连接信息插入 conntrack 表以记录连接。
目的端回包的时候内核从 conntrack 表匹配连接并反向 NAT，这样原路返回形成一个完整的连接链路。

但是 Linux Bridge（Linux 网桥）是一个虚拟的二层转发设备，而 iptables conntrack 工作在三层。
所以问题来了，如果直接访问同一网桥内的地址，会走二层转发，不经过 conntrack，由于没有原路返回，客户端与服务端的通信就不在一个 「频道」 上，不认为处在同一个连接，也就无法正常通信。

设置 bridge-nf-call-iptables 这个内核参数 (设置为 1)，表示 bridge 设备在二层转发时也去调用 iptables 配置的三层规则 (包含 conntrack)，
所以开启这个参数就能够解决上述 Service 同节点通信问题。
