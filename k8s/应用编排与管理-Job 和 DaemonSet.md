#### Job：管理任务的控制器



- 首先 kubernetes 的 Job 是一个管理任务的控制器，它可以创建一个或多个 Pod 来指定 Pod 的数量，并可以监控它是否成功地运行或终止；
- 我们可以根据 Pod 的状态来给 Job 设置重置的方式及重试的次数；
- 我们还可以根据依赖关系，保证上一个任务运行完成之后再运行下一个任务；
- 同时还可以控制任务的并行度，根据并行度来确保 Pod 运行过程中的并行次数和总体完成大小。

⾮并⾏ Job：通常创建⼀个 Pod 直⾄其成功结束 

固定结束次数的 Job：设置 .spec.completions ，创建多个 Pod，直到 .spec.completions 个 Pod 成功结束 

带有⼯作队列的并⾏ Job：设置 .spec.Parallelism 但不设置 .spec.completions ，当所有 Pod 结束并且⾄少⼀个成功时，Job 就认为是成功

![img](https://edu.aliyun.com/files/course/2021/04-02/1646306b25ea647399.jpeg)



Kubernetes ⽀持以下⼏种 Job： 

⾮并⾏ Job：通常创建⼀个 Pod 直⾄其成功结束 

固定结束次数的 Job：设置 .spec.completions ，创建多个 Pod，直到 .spec.completions 个 Pod 成功结束 

带有⼯作队列的并⾏ Job：设置 .spec.Parallelism 但不设置 .spec.completions ，当所有 Pod 结束并且⾄少⼀个成功时，Job 就认为是成功

![image-20210628171951843](C:\Users\Dongzihao\AppData\Roaming\Typora\typora-user-images\image-20210628171951843.png)



#### cronjob

![img](https://edu.aliyun.com/files/course/2021/04-02/164850284db3319326.png)

- **schedule**：schedule 这个字段主要是设置时间格式，它的时间格式和 Linux 的 crontime 是一样的，所以直接根据 Linux 的 crontime 书写格式来书写就可以了。举个例子： */1 指每分钟去执行一下 Job，这个 Job 需要做的事情就是打印出大约时间，然后打印出“Hello from the kubernetes cluster” 这一句话；

 

- **startingDeadlineSeconds：**即：每次运行 Job 的时候，它最长可以等多长时间，有时这个 Job 可能运行很长时间也不会启动。所以这时，如果超过较长时间的话，CronJob 就会停止这个 Job；

 

- **concurrencyPolicy**：就是说是否允许并行运行。所谓的并行运行就是，比如说我每分钟执行一次，但是这个 Job 可能运行的时间特别长，假如两分钟才能运行成功，也就是第二个 Job 要到时间需要去运行的时候，上一个 Job 还没完成。如果这个 policy 设置为 true 的话，那么不管你前面的 Job 是否运行完成，每分钟都会去执行；如果是 false，它就会等上一个 Job 运行完成之后才会运行下一个；

 

- **JobsHistoryLimit：**这个就是每一次 CronJob 运行完之后，它都会遗留上一个 Job 的运行历史、查看时间。当然这个额不能是无限的，所以需要设置一下历史存留数，一般可以设置默认 10 个或 100 个都可以，这主要取决于每个人集群不同，然后根据每个人的集群数来确定这个时间。



### DaemonSet

DaemonSet 最常用的点在于以下几点内容：

 

- 首先是存储，GlusterFS 或者 Ceph 之类的东西，需要每台节点上都运行一个类似于 Agent 的东西，DaemonSet 就能很好地满足这个诉求；

 

- 另外，对于日志收集，比如说 logstash 或者 fluentd，这些都是同样的需求，需要每台节点都运行一个 Agent，这样的话，我们可以很容易搜集到它的状态，把各个节点里面的信息及时地汇报到上面；

 

- 还有一个就是，需要每个节点去运行一些监控的事情，也需要每个节点去运行同样的事情，比如说 Promethues 这些东西，也需要 DaemonSet 的支持。



![img](https://edu.aliyun.com/files/course/2021/04-02/1656331dd189550131.png)



NODE SELECTOR 在 DaemonSet 里面非常有用。有时候我们可能希望只有部分节点去运行这个 pod 而不是所有的节点，所以有些节点上被打了标的话，DaemonSet 就只运行在这些节点上。比如，我只希望 master 节点运行某些 pod，或者只希望 Worker 节点运行某些 pod，就可以使用这个 NODE SELECTOR。

