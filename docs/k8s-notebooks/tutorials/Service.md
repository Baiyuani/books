### Service：Kubernetes 中的服务返现与负载均衡



![img](https://edu.aliyun.com/files/course/2021/04-06/110945942bb5903225.png)





### Service 语法

![img](https://edu.aliyun.com/files/course/2021/04-06/111018a9d728049128.png)

![img](https://edu.aliyun.com/files/course/2021/04-06/11105603a4ef876654.png)

Service 有四种类型： 

- ClusterIP：默认类型，⾃动分配⼀个仅 cluster 内部可以访问的虚拟 IP 

- NodePort：在 ClusterIP 基础上为 Service 在每台机器上绑定⼀个端⼝，这样就可以通过NodeIp:NodePort 来访问该服务。如果 kube-proxy 设置了 --nodeportaddresses=10.240.0.0/16 ，那么仅该 NodePort 仅对设置在范围内的 IP 有效。 

- LoadBalancer：在 NodePort 的基础上，借助 cloud provider 创建⼀个外部的负载均衡器，并将 请求转发到 NodeIp:NodePort 

- ExternalName：将服务通过 DNS CNAME 记录⽅式转发到指定的域名（通过 spec.externlName 设定）。 另外，也可以将已有的服务以 Service 的形式加⼊到 Kubernetes 集群中来，只需要在创建 Service 的 时候不指定 Label selector，⽽是在 Service 创建好后⼿动为其添加 endpoint





### ClusterIP

根据是否生成ClusterIP又可分为普通Service和Headless Service两类：

- 普通Service：通过为Kubernetes的Service分配一个集群内部可访问的固定虚拟IP（Cluster IP），实现集群内的访问。为最常见的方式。
- Headless Service：该服务不会分配Cluster IP，也不通过kube-proxy做反向代理和负载均衡。而是通过DNS提供稳定的网络ID来访问，DNS会将headless service的后端直接解析为podIP列表。主要供StatefulSet使用。

kafka0-kafka.svc.XX ====> pod ip列表 （ 客户端获得这个列表，自行处理)
service ip => cluster ip =>kube proxy 负载均衡(RR) => pod ip



### Headless Service

service 有一个特别的形态就是 Headless Service。service 创建的时候可以指定 clusterIP:None，告诉 K8s 说我不需要 clusterIP（就是刚才所说的集群里面的一个虚拟 IP），然后 K8s 就不会分配给这个 service 一个虚拟 IP 地址

 ![img](https://edu.aliyun.com/files/course/2021/04-06/1112215e2648446658.png)

它是这样来操作的：pod 可以直接通过 service_name 用 DNS 的方式解析到所有后端 pod 的 IP 地址，通过 DNS 的 A 记录的方式会解析到所有后端的 Pod 的地址，由客户端选择一个后端的 IP 地址，这个 A 记录会随着 pod 的生命周期变化，返回的 A 记录列表也发生变化，这样就要求客户端应用要从 A 记录把所有 DNS 返回到 A 记录的列表里面 IP 地址中，客户端自己去选择一个合适的地址去访问 pod。



### 集群内访问 Service

 

在集群里面，其他 pod 访问这个 service有三种方式：

 

- 首先我们可以通过 service 的虚拟 IP 去访问，比如说刚创建的 my-service 这个服务，通过 kubectl get svc 或者 kubectl discribe service 都可以看到它的虚拟 IP 地址是 172.29.3.27，端口是 80，然后就可以通过这个虚拟 IP 及端口在 pod 里面直接访问到这个 service 的地址。

 

- 第二种方式直接访问服务名，依靠 DNS 解析，就是同一个 namespace 里 pod 可以直接通过 service 的名字去访问到刚才所声明的这个 service。不同的 namespace 里面，我们可以通过 service 名字加“.”，然后加 service 所在的哪个 namespace 去访问这个 service，例如我们直接用 curl 去访问，就是 my-service:80 就可以访问到这个 service。

 

- 第三种是通过环境变量访问，在同一个 namespace 里的 pod 启动时，K8s 会把 service 的一些 IP 地址、端口，以及一些简单的配置，通过环境变量的方式放到 K8s 的 pod 里面。在 K8s pod 的容器启动之后，通过读取系统的环境变量比读取到 namespace 里面其他 service 配置的一个地址，或者是它的端口号等等。比如在集群的某一个 pod 里面，可以直接通过 curl $ 取到一个环境变量的值，比如取到 MY_SERVICE_SERVICE_HOST 就是它的一个 IP 地址，MY_SERVICE 就是刚才我们声明的 MY_SERVICE，SERVICE_PORT 就是它的端口号，这样也可以请求到集群里面的 MY_SERVICE 这个 service。

 

### 向集群外暴露 Service

一个是 NodePort，一个是 LoadBalancer。

 

- NodePort 的方式就是在集群的 node 上面（即集群的节点的宿主机上面）去暴露节点上的一个端口，这样相当于在节点的一个端口上面访问到之后就会再去做一层转发，转发到虚拟的 IP 地址上面，就是刚刚宿主机上面 service 虚拟 IP 地址。

 

- LoadBalancer 类型就是在 NodePort 上面又做了一层转换，刚才所说的 NodePort 其实是集群里面每个节点上面一个端口，LoadBalancer 是在所有的节点前又挂一个负载均衡。比如在阿里云上挂一个 SLB，这个负载均衡会提供一个统一的入口，并把所有它接触到的流量负载均衡到每一个集群节点的 node pod 上面去。然后 node pod 再转化成 ClusterIP，去访问到实际的 pod 上面。



###  架构设计

![img](https://edu.aliyun.com/files/course/2021/04-06/112745100947316833.png)

K8s 分为 master 节点和 worker 节点：

- master 里面主要是 K8s 管控的内容；
- worker 节点里面是实际跑用户应用的一个地方。

 

在 K8s master 节点里面有 APIServer，就是统一管理 K8s 所有对象的地方，所有的组件都会注册到 APIServer 上面去监听这个对象的变化，比如说我们刚才的组件 pod 生命周期发生变化，这些事件。

 

这里面最关键的有三个组件：

- 一个是 Cloud Controller Manager，负责去配置 LoadBalancer 的一个负载均衡器给外部去访问；
- 另外一个就是 Coredns，就是通过 Coredns 去观测 APIServer 里面的 service 后端 pod 的一个变化，去配置 service 的 DNS 解析，实现可以通过 service 的名字直接访问到 service 的虚拟 IP，或者是 Headless 类型的 Service 中的 IP 列表的解析；
- 然后在每个 node 里面会有 kube-proxy 这个组件，它通过监听 service 以及 pod 变化，然后实际去配置集群里面的 node pod 或者是虚拟 IP 地址的一个访问。

 

实际访问链路是什么样的呢？比如说从集群内部的一个 Client Pod3 去访问 Service，就类似于刚才所演示的一个效果。Client Pod3 首先通过 Coredns 这里去解析出 ServiceIP，Coredns 会返回给它 ServiceName 所对应的 service IP 是什么，这个 Client Pod3 就会拿这个 Service IP 去做请求，它的请求到宿主机的网络之后，就会被 kube-proxy 所配置的 iptables 或者 IPVS 去做一层拦截处理，之后去负载均衡到每一个实际的后端 pod 上面去，这样就实现了一个负载均衡以及服务发现。

 

对于外部的流量，比如说刚才通过公网访问的一个请求。它是通过外部的一个负载均衡器 Cloud Controller Manager 去监听 service 的变化之后，去配置的一个负载均衡器，然后转发到节点上的一个 NodePort 上面去，NodePort 也会经过 kube-proxy 的一个配置的一个 iptables，把 NodePort 的流量转换成 ClusterIP，紧接着转换成后端的一个 pod 的 IP 地址，去做负载均衡以及服务发现。这就是整个 K8s 服务发现以及 K8s Service 整体的结构。
