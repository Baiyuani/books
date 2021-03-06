## StatefulSet：主要面向有状态应用管理的控制器

 

其实现在社区很多无状态应用也通过 StatefulSet 来管理，通过这节课程，大家也会明白为什么我们将部分无状态应用也通过 StatefulSet 来管理。

 

![img](https://edu.aliyun.com/files/course/2021/04-06/165751fbd271972438.png)

 

如上图右侧所示，StatefulSet 中的 Pod 都是有序号的，从 0 开始一直到定义的 replica 数量减一。每个 Pod 都有独立的网络标识：一个 hostname、一块独立的 pvc 以及 pv 存储。这样的话，同一个 StatefulSet 下不同的 Pod，有不同的网络标识、有自己独享的存储盘，这就能很好地满足了绝大部分有状态应用的需求。

 

如上图右侧所示：

 

- 首先，每个 Pod 会有 Order 序号，会按照序号来创建，删除和更新 Pod；
- 其次，通过配置一个 headless Service，使每个 Pod 有一个唯一的网络标识 (hostname)；
- 第三，通过配置 pvc 模板，就是 pvc template，使每个 Pod 有一块或者多块 pv 存储盘；
- 最后，支持一定数量的灰度发布。比如现在有三个副本的 StatefulSet，我们可以指定只升级其中的一个或者两个，更甚至是三个到新版本。通过这样的方式，来达到灰度升级的目的。



## Pod 的版本

![img](https://edu.aliyun.com/files/course/2021/04-06/1701084e0f62249639.png)

 

Deployment 使用 ReplicaSet 来管理 Pod 的版本和所期望的 Pod 数量，但是在 StatefulSet 中，是由 StatefulSet Controller 来管理下属的 Pod，因此 StatefulSet 通过 Pod 的 label 来标识这个 Pod 所属的版本，这里叫 controller-revision-hash。这个 label 标识和 Deployment 以及 StatefulSet 在 Pod 中注入的 Pod template hash 是类似的。

### 更新镜像

![img](https://edu.aliyun.com/files/course/2021/04-06/17023391c956731739.png)

 

通过执行上图的命令，可以看到上图下方的 StatefulSet 配置中，已经把 StatefulSet 中的 image 更新到了 mainline 新版本。

 

### 查看新版本状态

![img](https://edu.aliyun.com/files/course/2021/04-06/1703059bf621888992.png)

 

通过 get pod 命令查询 Revision hash，可以看到三个 Pod 后面的 controller-revision-hash 都已经升级到了新的 Revision hash，后面变成了 7c55499668。通过这三个 Pod 创建的时间可以发现：序号为 2 的 Pod 创建的是最早的，之后是序号是 1 和 0。这表示在升级的过程中，真实的升级顺序为 2-1-0，通过这么一个倒序的顺序来逐渐把 Pod 升级为新版本，并且我们升级的 Pod，还复用了之前 Pod 使用的 PVC。所以之前在 PV 存储盘中的数据，仍然会挂载到新的 Pod 上。

 

上图右上方是在 StatefulSet 的 status 中看到的数据，这里有几个重要的字段：

 

- **currentReplica**：表示当前版本的数量
- **currentRevision：** 表示当前版本号
- **updateReplicas**：表示新版本的数量
- **updateRevision：**表示当前要更新的版本号

 

当然这里也能看到 currentReplica 和 updateReplica，以及 currentRevision 和 updateRevision 都是一样的，这就表示所有 Pod 已经升级到了所需要的版本。



# 架构设计

## 管理模式

StatefulSet 可能会创建三种类型的资源。

 

- **第一种资源：ControllerRevision**

 

**通过这个资源，StatefulSet 可以很方便地管理不同版本的 template 模板。**

 

举个例子：比如上文中提到的 nginx，在创建之初拥有的第一个 template 版本，会创建一个对应的 ControllerRevision。而当修改了 image 版本之后，StatefulSet Controller 会创建一个新的 ControllerRevision，大家可以理解为每一个 ControllerRevision 对应了每一个版本的 Template，也对应了每一个版本的 ControllerRevision hash。其实在 Pod label 中定义的 ControllerRevision hash，就是 ControllerRevision 的名字。通过这个资源 StatefulSet Controller 来管理不同版本的 template 资源。

 

- **第二个资源：PVC**

 

**如果在 StatefulSet 中定义了 volumeClaimTemplates，StatefulSet 会在创建 Pod 之前，先根据这个模板创建 PVC，并把 PVC 加到 Pod volume 中。**

 

如果用户在 spec 的 pvc 模板中定义了 volumeClaimTemplates，StatefulSet 在创建 Pod 之前，根据模板创建 PVC，并加到 Pod 对应的 volume 中。当然也可以在 spec 中不定义 pvc template，那么所创建出来的 Pod 就不会挂载单独的一个 pv。

 

- **第三个资源：Pod**

 

**StatefulSet 按照顺序创建、删除、更新 Pod，每个 Pod 有唯一的序号。**

 

![img](https://edu.aliyun.com/files/course/2021/04-06/17144777bf02494608.png)

 

如上图所示，StatefulSet Controller 是 Owned 三个资源：ControllerRevision、Pod、PVC。

 

这里不同的地方在于，当前版本的 StatefulSet 只会在 ControllerRevision 和 Pod 中添加 OwnerReference，而不会在 PVC 中添加 OwnerReference。之前的课程中提到过，拥有 OwnerReference 的资源，在管理的这个资源进行删除的默认情况下，会关联级联删除下属资源。因此默认情况下删除 StatefulSet 之后，StatefulSet 创建的 ControllerRevision 和 Pod 都会被删除，但是 PVC 因为没有写入 OwnerReference，PVC 并不会被级联删除。

 

## StatefulSet 控制器

![img](https://edu.aliyun.com/files/course/2021/04-06/171525d1151e928278.png)

 

上图为 StatefulSet 控制器的工作流程，下面来简单介绍一下整个工作处理流程。

 

首先通过注册 Informer 的 Event Handler(事件处理)，来处理 StatefulSet 和 Pod 的变化。在 Controller 逻辑中，每一次收到 StatefulSet 或者是 Pod 的变化，都会找到对应的 StatefulSet 放到队列。紧接着从队列取出来处理后，先做的操作是 Update Revision，也就是先查看当前拿到的 StatefulSet 中的 template，有没有对应的 ControllerRevision。如果没有，说明 template 已经更新过，Controller 就会创建一个新版本的 Revision，也就有了一个新的 ControllerRevision hash 版本号。

 

然后 Controller 会把所有版本号拿出来，并且按照序号整理一遍。这个整理的过程中，如果发现有缺少的 Pod，它就会按照序号去创建，如果发现有多余的 Pod，就会按照序号去删除。当保证了 Pod 数量和 Pod 序号满足 Replica 数量之后，Controller 会去查看是否需要更新 Pod。也就是说这两步的区别在于，Manger pods in order 去查看所有的 Pod 是否满足序号；而后者 Update in order 查看 Pod 期望的版本是否符合要求，并且通过序号来更新。

 

Update in order 其更新过程如上图所示，其实这个过程比较简单，就是删除 Pod。删除 Pod 之后，其实是在下一次触发事件，Controller 拿到这个 success 之后会发现缺少 Pod，然后再从前一个步骤 Manger pod in order 中把新的 Pod 创建出来。在这之后 Controller 会做一次 Update status，也就是之前通过命令行看到的 status 信息。

 

通过整个这样的一个流程，StatefulSet 达到了管理有状态应用的能力。

 

## 扩容模拟

![img](https://edu.aliyun.com/files/course/2021/04-06/171557de1933097407.png)

假设 StatefulSet 初始配置 replicas 为 1，有一个 Pod0。那么将 replicas 从 1 修改到 3 之后，其实我们是先创建 Pod1，默认情况是等待 Pod1 状态 READY 之后，再创建 Pod2。

 

通过上图可以看到每个 StatefulSet 下面的 Pod 都是从序号 0 开始创建的。因此一个 replicas 为 N 的 StatefulSet，它创建出来的 Pod 序号为 [0,N)，0 是开曲线，N 是闭曲线，也就是当 N>0 的时候，序号为 0 到 N-1。

 

## 扩缩容管理策略

![img](https://edu.aliyun.com/files/course/2021/04-06/171630e14276728312.png)

 

可能有的同学会有疑问：如果我不想按照序号创建和删除，那 StatefulSet 也支持其它的创建和删除的逻辑，这也就是为什么社区有些人把无状态应用也通过 StatefulSet 来管理。它的好处是它能拥有唯一的网络标识以及网络存储，同时也能通过并发的方式进行扩缩容。

 

StatefulSet.spec 中有个字段叫 podMangementPolicy 字段，这个字段的可选策略为 OrderedReady 和 Parallel，默认情况下为前者。

 

如我们刚才创建的例子，没有在 spec 中定义 podMangementPolicy。那么 Controller 默认 OrderedReady 作为策略，然后在 OrderedReady 情况下，扩缩容就严格按照 Order 顺序来执行，必须要等前面的 Pod 状态为 Ready 之后，才能扩容下一个 Pod。在缩容的时候，倒序删除，序号从大到小进行删除。

 

举个例子，上图右侧中，从 Pod0 扩容到 Pod0、Pod1、Pod2 的时候，必须先创建 Pod1，等 Pod1 Ready 之后再创建 Pod2。其实还存在一种可能性：比如在创建 Pod1 的时候，Pod0 因为某些原因，可能是宿主机的原因或者是应用本身的原因，Pod0 变成 NotReady 状态。这时 Controller 也不会创建 Pod2，所以不只是我们所创建 Pod 的前一个 Pod 要 Ready，而是前面所有的 Pod 都要 Ready 之后，才会创建下一个 Pod。上图中的例子，如果要创建 Pod2，那么 Pod:0、Pod1 都要 ready。

 

另一种策略叫做 Parallel，顾名思义就是并行扩缩容，不需要等前面的 Pod 都 Ready 或者删除后再处理下一个。

 

## 发布模拟

![img](https://edu.aliyun.com/files/course/2021/04-06/17170519addd046118.png)

 

假设这里的 StatefulSet template1 对应逻辑上的 Revision1，这时 StatefulSet 下面的三个 Pod 都属于 Revision1 版本。在我们修改了 template，比如修改了镜像之后，Controller 是通过倒序的方式逐一升级 Pod。上图中可以看到 Controller 先创建了一个 Revision2，对应的就是创建了 ControllerRevision2 这么一个资源，并且将 ControllerRevision2 这个资源的 name 作为一个新的 Revision hash。在把 Pod2 升级为新版本后，逐一删除 Pod0、Pod1，再去创建 Pod0、Pod1。

 

它的逻辑其实很简单，在升级过程中 Controller 会把序号最大并且符合条件的 Pod 删除掉，那么删除之后在下一次 Controller 在做 reconcile 的时候，它会发现缺少这个序号的 Pod，然后再按照新版本把 Pod 创建出来。

 

## spec 字段解析

![img](https://edu.aliyun.com/files/course/2021/04-06/171748cabf1f485440.png)

 

首先来看一下 spec 中前几个字段，Replica 和 Selector 都是我们比较熟悉的字段。

 

- Replica 主要是期望的数量；
- Selector 是事件选择器，必须匹配 spec.template.metadata.labels 中定义的条件；
- Template：Pod 模板，定义了所要创建的 Pod 的基础信息模板；
- VolumeClaimTemplates：PVC 模板列表，如果在 spec 中定义了这个，PVC 会先于 Pod 模板 Template 进行创建。在 PVC 创建完成后，把创建出来的 PVC name 作为一个 volume 注入到根据 Template 创建出来的 Pod 中。

 

![img](https://edu.aliyun.com/files/course/2021/04-06/171823f01cc3280915.png)

 

- ServiceName：对应 Headless Service 的名字。当然如果有人不需要这个功能的时候，会给 Service 定一个不存在的 value，Controller 也不会去做校验，所以可以写一个 fake 的 ServiceName。但是这里推荐每一个 Service 都要配置一个 Headless Service，不管 StatefulSet 下面的 Pod 是否需要网络标识；
- PodMangementPolicy：Pod 管理策略。前面提到过这个字段的可选策略为 OrderedReady 和 Parallel，默认情况下为前者；
- UpdataStrategy：Pod 升级策略。这是一个结构体，下面再详细介绍；
- RevisionHistoryLimit：保留历史 ControllerRevision 的数量限制(默认为 10)。需要注意的一点是，这里清楚的版本，必须没有相关的 Pod 对应这些版本，如果有 Pod 还在这个版本中，这个 ControllerRevision 是不能被删除的。

 

## 升级策略字段解析

![img](https://edu.aliyun.com/files/course/2021/04-06/1719015e1792970047.png)

 

在上图右侧可以看到 StatefulSetUpdateStrategy 有个 type 字段，这个 type 定义了两个类型：一个是 RollingUpdate；一个是OnDelete。

 

RollingUpdate 其实跟 Deployment 中的升级是有点类似的，就是根据滚动升级的方式来升级。

 

OnDelete 是在删除的时候升级，叫做禁止主动升级，Controller 并不会把存活的 Pod 做主动升级，而是通过 OnDelete 的方式。比如说当前有三个旧版本的 Pod，但是升级策略是 OnDelete，所以当更新 spec 中镜像的时候，Controller 并不会把三个 Pod 逐一升级为新版本，而是当我们缩小 Replica 的时候，Controller 会先把 Pod 删除掉，当我们下一次再进行扩容的时候，Controller 才会扩容出来新版本的 Pod。

 

在 RollingUpdateStatefulSetSetStrategy 中，可以看到有个字段叫 Partition。这个 Partition 表示滚动升级时，保留旧版本 Pod 的数量。很多刚结束 StatefulSet 的同学可能会认为这个是灰度新版本的数量，这是错误的。

 

举个例子：假设当前有个 replicas 为 10 的 StatefulSet，当我们更新版本的时候，如果 Partition 是 8，并不是表示要把 8 个 Pod 更新为新版本，而是表示需要保留 8 个 Pod 为旧版本，只更新 2 个新版本作为灰度。当 Replica 为 10 的时候，下面的 Pod 序号为 [0,9)，因此当我们配置 Partition 为 8 的时候，其实还是保留 [0,7) 这 8个 Pod 为旧版本，只有 [8,9) 进入新版本。

 

总结一下，假设 replicas=N，Partition=M (M<N) ，则最终旧版本 Pod 为 [0，M) ,新版本 Pod 为 [M,N)。通过这样一个 Partition 的方式来达到灰度升级的目的，这是目前 Deployment 所不支持的。

