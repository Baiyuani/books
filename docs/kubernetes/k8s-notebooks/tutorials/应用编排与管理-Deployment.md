附：副本集（Replica Set，RS/ReplicationController RC） 

ReplicationController（也简称为 rc）⽤来确保容器应⽤的副本数始终保持在⽤户定义的副本数，即如 果有容器异常退出，会⾃动创建新的 Pod 来替代；⽽异常多出来的容器也会⾃动回收。 ReplicationController 的典型应⽤场景包括确保健康 Pod 的数量、弹性伸缩、滚动升级以及应⽤多版 本发布跟踪等。 在新版本的 Kubernetes 中建议使⽤ ReplicaSet（也简称为 rs）来取代 ReplicationController。 ReplicaSet 跟 ReplicationController 没有本质的不同，只是名字不⼀样，并且 ReplicaSet ⽀持集合式 的 selector（ReplicationController 仅⽀持等式）。 虽然也 ReplicaSet 可以独⽴使⽤，但建议使⽤ Deployment 来⾃动管理 ReplicaSet，这样就⽆需担⼼ 跟其他机制的不兼容问题（⽐如 ReplicaSet 不⽀持 rolling-update 但 Deployment ⽀持），并且还⽀ 持版本记录、回滚、暂停升级等⾼级特性。

### Deployment 

Deployment是⼀个⽐RS应⽤模式更⼴的API对象，可以是创建⼀个新的服务，更新⼀个新的服务，也可 以是滚动升级⼀个服务。滚动升级⼀个服务。 实际是创建⼀个新的RS，然后逐渐将新RS中副本数增加到理想状态，将旧RS中的副本数减⼩到0的复合 操作；这样⼀个复合操作⽤⼀个RS是不太好描述的，所以⽤⼀个更通⽤的Deployment来描述。以K8s 的发展⽅向，未来对所有⻓期伺服型的的业务的管理，都会通过Deployment来管理。

![img](https://edu.aliyun.com/files/course/2021/04-02/16221461bfc1145102.png)



kubectl create -f dpl.yaml

kubectl set image deployment.v1.apps/nginx-deployment nginx=nginx:1.9.1

kubectl rollout undo deployment/DEPLOYMENT	#回滚到上一版本

kubectl rollout history deployment/DEPLOYMENT	#查看历史版本

kubectl rollout undo deployment/DEPLOYMENT --to-revision=2	#回滚到指定版本

### DeploymeStatus

![img](https://edu.aliyun.com/files/course/2021/04-02/162522201508985927.png)

以 Processing 为例：Processing 指的是 Deployment 正在处于扩容和发布中。比如说 Processing 状态的 deployment，它所有的 replicas 及 Pod 副本全部达到最新版本，而且是 available，这样的话，就可以进入 complete 状态。而 complete 状态如果发生了一些扩缩容的话，也会进入 processing 这个处理工作状态。

 

如果在处理过程中遇到一些问题：比如说拉镜像失败了，或者说 readiness probe 检查失败了，就会进入 failed 状态；如果在运行过程中即 complete 状态，中间运行时发生了一些 pod readiness probe 检查失败，这个时候 deployment 也会进入 failed 状态。进入 failed 状态之后，除非所有点 replicas 均变成 available，而且是 updated 最新版本，deployment 才会重新进入 complete 状态。



### deployment更新

假设做了一次更新，这个时候 get.pod 其实可以看到：当前的 pod 其实是有两个旧版本的处于 running，另一个旧版本是在删除中；而两个新版本的 pod，一个已经进入 running，一个还在 creating 中。

 

这时我们可用的 pod 数量即非删除状态的 pod 数量，其实是 4 个，已经超过了 replica 原先在 deployment 设置的数量 3 个。这个原因是我们在 deployment 中有 maxavailable 和 maxsugar 两个操作，这两个配置可以限制我们在发布过程中的一些策略。

![img](https://edu.aliyun.com/files/course/2021/04-02/163142eea47b742451.png)



### 架构设计

1. 管理模式

![img](https://edu.aliyun.com/files/course/2021/04-02/163427311491414981.png)



2. Deployment 控制器

我们所有的控制器都是通过 Informer 中的 Event 做一些 Handler 和 Watch。这个地方 Deployment 控制器，其实是关注 Deployment 和 ReplicaSet 中的 event，收到事件后会加入到队列中。而 Deployment controller 从队列中取出来之后，它的逻辑会判断 Check Paused，这个 Paused 其实是 Deployment 是否需要新的发布，如果 Paused 设置为 true 的话，就表示这个 Deployment 只会做一个数量上的维持，不会做新的发布。

![img](https://edu.aliyun.com/files/course/2021/04-02/164408812526203785.png)

如上图，可以看到如果 Check paused 为 Yes 也就是 true 的话，那么只会做 Sync replicas。也就是说把 replicas sync 同步到对应的 ReplicaSet 中，最后再 Update Deployment status，那么 controller 这一次的 ReplicaSet 就结束了。

 

那么如果 paused 为 false 的话，它就会做 Rollout，也就是通过 Create 或者是 Rolling 的方式来做更新，更新的方式其实也是通过 Create/Update/Delete 这种 ReplicaSet 来做实现的。



3. ReplicaSet 控制器

![img](https://edu.aliyun.com/files/course/2021/04-02/1635197e5585941218.png)

当 Deployment 分配 ReplicaSet 之后，ReplicaSet 控制器本身也是从 Informer 中 watch 一些事件，这些事件包含了 ReplicaSet 和 Pod 的事件。从队列中取出之后，ReplicaSet controller 的逻辑很简单，就只管理副本数。也就是说如果 controller 发现 replicas 比 Pod 数量大的话，就会扩容，而如果发现实际数量超过期望数量的话，就会删除 Pod。

 

上面 Deployment 控制器的图中可以看到，Deployment 控制器其实做了更复杂的事情，包含了版本管理，而它把每一个版本下的数量维持工作交给 ReplicaSet 来做。

 

![img](https://edu.aliyun.com/files/course/2021/04-02/163750eb6a68310445.png)

![img](https://edu.aliyun.com/files/course/2021/04-02/163819beb2d1676902.png)



4. spec字段解析

- minReadySeconds：Deployment 会根据 Pod ready 来看 Pod 是否可用，但是如果我们设置了 MinReadySeconds 之后，比如设置为 30 秒，那 Deployment 就一定会等到 Pod ready 超过 30 秒之后才认为 Pod 是 available 的。Pod available 的前提条件是 Pod ready，但是 ready 的 Pod 不一定是 available 的，它一定要超过 MinReadySeconds 之后，才会判断为 available；

 

- revisionHistoryLimit：保留历史 revision，即保留历史 ReplicaSet 的数量，默认值为 10 个。这里可以设置为一个或两个，如果回滚可能性比较大的话，可以设置数量超过 10；

 

- paused：paused 是标识，Deployment 只做数量维持，不做新的发布，这里在 Debug 场景可能会用到；

 

- progressDeadlineSeconds：前面提到当 Deployment 处于扩容或者发布状态时，它的 condition 会处于一个 processing 的状态，processing 可以设置一个超时时间。如果超过超时时间还处于 processing，那么 controller 将认为这个 Pod 会进入 failed 的状态。

![img](https://edu.aliyun.com/files/course/2021/04-02/1639004cc8c5462759.png)



- maxUnavailable：滚动过程中最多有多少个 Pod 不可用；
- maxSurge：滚动过程中最多存在多少个 Pod 超过预期 replicas 数量。

