---
tags:
  - k8s
  - calico
  - network
---
# calico

> Update:2024/1/9

## [architecture](https://docs.tigera.io/calico/latest/reference/architecture/overview)

![architecture](https://docs.tigera.io/assets/images/architecture-calico-deae813300e472483f84d6bfb49650ab.svg)

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


## [Network Configuration](https://docs.tigera.io/calico/latest/networking/configuring/)

- 操作前阅读[确定最佳网络选项](https://docs.tigera.io/calico/latest/networking/determine-best-networking)

!!! note 

    一般集群建议：
    1. 使用overlay网络的ipip模式（vxlan性能稍差一点），设置为仅跨子网时进行封装。但还需实际测试环境网络是否有拦截ipip流量，否则也可以使用vxlan
    2. xvlan模式几乎可以在任何环境中运行，可以将该模式作为保底方案（`IPPool`设置`vxlanMode: Always`）

### 配置calico与底层网络的BGP对等连接

!!! note

    calico与底层网络的BGP对等连接需要对底层网络有一定的配置操作，一般情况下使用overlay覆盖集群所有工作负载即可，仅有公布podip等类似需求是考虑BGP

BGP是用于在网络中的路由器之间交换路由信息的标准协议。每台运行 BGP 的路由器都有一个或多个BGP 对等体- 它们通过 BGP 与其他路由器进行通信。您可以将 Calico 网络视为在每个节点上提供一个虚拟路由器。

### [overlay networking](https://docs.tigera.io/calico/latest/networking/configuring/vxlan-ipip)

!!! warning

    - IP in IP supports only IPv4 addresses
    - VXLAN in IPv6 is only supported for kernel versions ≥ 4.19.1 or redhat kernel version ≥ 4.18.0

Calico 支持两种类型的封装：VXLAN 和 IP in IP。在某些不支持 IP in IP 的环境中（例如 Azure）支持 VXLAN。 VXLAN 的每个数据包开销稍高，因为标头较大，但除非您运行网络密集型工作负载，否则您通常不会注意到差异。两种封装类型之间的另一个小区别是 Calico 的 VXLAN 实现不使用 BGP，而 Calico 的 IP in IP 实现在 Calico 节点之间使用 BGP。

!!! note

    - 使用tigera-operator安装，且未明确配置时，默认使用ipip Always的overlay网络
    - 部分云平台会拦截ipip流量，使用时可两种类型都试试

Calico 可以选择选择性地仅封装跨越子网边界的流量。建议使用IP in IP 或 VXLAN 的跨子网选项（即子网内部不使用封装，仅跨子网时使用），以最大限度地减少封装开销。

- `kubectl edit ippools default-ipv4-ippool`

    ```yaml
    apiVersion: projectcalico.org/v3
    kind: IPPool
    metadata:
      creationTimestamp: "2024-01-09T02:54:32Z"
      name: default-ipv4-ippool
      resourceVersion: "30050"
      uid: cc893d43-213c-4c1d-8f58-8de477cae79c
    spec:
      allowedUses:
      - Workload
      - Tunnel
      blockSize: 26
      cidr: 10.95.0.0/16
      ipipMode: CrossSubnet
      natOutgoing: true
      nodeSelector: all()
      vxlanMode: Never
    ```

### [配置MTU](https://docs.tigera.io/calico/latest/networking/configuring/mtu)

> IP、VXLAN 和 WireGuard 协议中的 IP 中使用的额外覆盖标头会按标头大小减少最小 MTU。（IP in IP 使用 20 字节标头，IPv4 VXLAN 使用 50 字节标头，IPv6 VXLAN 使用 70 字节标头，IPv4 WireGuard 使用 60 字节标头，IPv6 WireGuard 使用 80 字节标头）。

!!! note

    如果服务器网卡MTU有调整，比如减少，则calico也应该相应的调整

## [故障排除和诊断](https://docs.tigera.io/calico/latest/operations/troubleshoot/troubleshooting)

## ipip vs vxlan

- ipip
  - 性能更好，资源占用少
  - 是将ip包封装在另一个ip包，所以只能传输ip包，其他非ip包将被丢弃，在设计上无法将非 IP 数据包作为下一个标头进行传输(IPIP 的范围仅限于两个 Intranet 之间单播 IP 数据包的隧道传输。所有广播和多播都在门口丢弃。此外，它严格来说是OSI 第 3 层— IPV4 和/或 IPV6 协议。它的主要优点是资源占用非常少。)
  - 仅支持ipv4

- vxlan
  - VxLAN 是OSI 第 2 层隧道协议。该协议的功能类似于桥接器/交换机。它通过隧道传输所有以太网流量，包括那些不可路由的数据包。
  - 支持ipv4和ipv6，如果集群使用了ipv6则只能使用vxlan
  - 相较ipip功能性更强，例如租户隔离，支持非ip数据包。但开销更大，IP in IP uses a 20-byte header, IPv4 VXLAN uses a 50-byte header, IPv6 VXLAN uses a 70-byte header
