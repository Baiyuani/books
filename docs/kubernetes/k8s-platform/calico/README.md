---
tags:
  - k8s
  - calico
  - network
---
# calico

## 一些技术细节

### NetworkPolicy

Kubernetes 网络策略是通过网络插件而不是 Kubernetes 本身来实现的。简单地创建网络策略资源而不使用网络插件来实现它，不会对网络流量产生影响。

Calico插件实现了全套 Kubernetes 网络策略功能。此外，Calico 支持Calico网络策略，提供 Kubernetes 网络策略之外的附加特性和功能。Kubernetes 和Calico网络策略无缝协作，因此您可以选择最适合您的策略，并根据需要进行混合和匹配。

### IPAM

Kubernetes 如何为 Pod 分配 IP 地址由所使用的 IPAM（IP 地址管理）插件决定。

Calico IPAM插件根据需要动态地将小块 IP 地址分配给节点，以有效地整体利用可用的 IP 地址空间。此外，Calico IPAM 支持高级功能，例如多个 IP 池、指定命名空间或 Pod 应使用的特定 IP 地址范围的能力，甚至是 Pod 应使用的特定 IP 地址。

### CNI 

Kubernetes 使用的 CNI（容器网络接口）插件决定了 Pod 如何连接到底层网络的详细信息。

Calico CNI 插件使用 L3 路由将Pod 连接到主机网络，而不需要 L2 桥接器。这简单易懂，并且比 kubenet 或 flannel 等其他常见替代方案更高效。

### Overlay VXLAN

覆盖网络允许 Pod 在节点之间进行通信，而底层网络不知道 Pod 或 Pod IP 地址。

不同节点上的 Pod 之间的数据包使用 VXLAN 进行封装，将每个原始数据包包装在使用节点 IP 的外部数据包中，并隐藏内部数据包的 Pod IP。Linux 内核可以非常有效地完成此操作，但它仍然会产生很小的开销，如果运行特别网络密集型工作负载，您可能希望避免这种情况。

相反，为了完整性，不使用覆盖的操作可提供最高性能的网络。离开 Pod 的数据包是通过网络传输的数据包。

### Routing

Calico路由使用其数据存储来分配和编程节点之间 pod 流量的路由，而无需 BGP。Calico路由支持单个子网内的未封装流量，以及跨多个子网的集群的选择性 VXLAN 封装。

### Datastore

Calico将集群的操作和配置状态存储在中央数据存储中。如果数据存储不可用，您的Calico网络将继续运行，但无法更新（新 Pod 无法联网、无法应用策略更改等）。

Calico有两个数据存储驱动程序可供选择
  - etcd - 用于直接连接到 etcd 集群
  - Kubernetes - 用于连接到 Kubernetes API 服务器

使用 Kubernetes 作为数据存储的优点是：
  - 它不需要额外的数据存储，因此安装和管理更简单
  - 您可以使用 Kubernetes RBAC 来控制对Calico资源的访问
  - 您可以使用 Kubernetes 审核日志记录来生成Calico资源更改的审核日志

为了完整起见，使用 etcd 作为数据存储的优点是：
  - 允许您在非 Kubernetes 平台（例如 OpenStack）上运行Calico
  - 允许分离 Kubernetes 和Calico资源之间的关注点，例如允许您独立扩展数据存储
  - 允许您运行包含多个 Kubernetes 集群的Calico集群，例如，具有Calico主机保护的裸机服务器与 Kubernetes 集群或多个 Kubernetes 集群联动。


## Network Configuration

### [配置MTU](https://docs.tigera.io/calico/latest/networking/configuring/mtu)

> IP、VXLAN 和 WireGuard 协议中的 IP 中使用的额外覆盖标头会按标头大小减少最小 MTU。（IP in IP 使用 20 字节标头，IPv4 VXLAN 使用 50 字节标头，IPv6 VXLAN 使用 70 字节标头，IPv4 WireGuard 使用 60 字节标头，IPv6 WireGuard 使用 80 字节标头）。

!!! note

    如果服务器网卡MTU有调整，比如减少，则calico也应该相应的调整

## [故障排除和诊断](https://docs.tigera.io/calico/latest/operations/troubleshoot/troubleshooting)

