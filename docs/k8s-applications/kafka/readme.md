https://github.com/bitnami/charts/tree/main/bitnami/kafka


```shell
# kafka 21.1.1
helm repo add bitnami https://charts.bitnami.com/bitnami
helm upgrade --install kafka bitnami/kafka -n {NS} \
--set global.storageClass='nfs-client' \
--set heapOpts='-Xmx1024m -Xms1024m' \
--set allowEveryoneIfNoAclFound=true 



--set superUsers='root' \
--set autoCreateTopicsEnable=true \
--set deleteTopicEnable=false \
```

- 测试
```shell
# 开两个终端
kubectl run kafka-client --restart='Never' --image docker.io/bitnami/kafka:3.4.0-debian-11-r2 --namespace saas --command -- sleep infinity
kubectl exec --tty -i kafka-client --namespace saas -- bash

# 分别执行以下命令
PRODUCER:
    kafka-console-producer.sh \
        --broker-list kafka-0.kafka-headless.saas.svc.cluster.local:9092 \
        --topic test

CONSUMER:
    kafka-console-consumer.sh \
        --bootstrap-server kafka.saas.svc.cluster.local:9092 \
        --topic test \
        --from-beginning
        
# 在生产者终端输入，可以在消费者终端看到消息即为正常        
```



```shell
# 列出topic
kafka-topics.sh --bootstrap-server kafka.saas.svc.cluster.local:9092 --list
```