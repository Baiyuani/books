# 使用helm部署

- [es官方charts](https://artifacthub.io/packages/helm/elastic/elasticsearch) 

- [filebeat官方charts](https://artifacthub.io/packages/helm/elastic/filebeat) 

- [kibana官方charts](https://artifacthub.io/packages/helm/elastic/kibana)


[filebeat-sidecar.yaml](filebeat-sidecar.yaml)

[values.yaml](values.yaml)


```shell
# 前提条件，执行以下命令将想要使用的存储类设置为默认，注意替换nfs-client
kubectl patch storageclass nfs-client -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
# 镜像在外网，拉不下来的话要手动上传

# https://github.com/elastic/helm-charts/tree/7.17/elasticsearch
#注：以下仅默认配置，生产使用需额外修改resource，storageSize，es地址等。
# 安装es
# 可以不启用ingress，kibana和filebeat只需要svc地址
helm repo add elastic https://helm.elastic.co
helm upgrade --install elasticsearch elastic/elasticsearch \
--version=7.17.3 \
--set ingress.enabled='true' \
--set ingress.hosts[0].host='es.local.domain' \
--set ingress.hosts[0].paths[0].path='\'  \
--set replicas=1 \
--set minimumMasterNodes=1 \
--set esJavaOpts='-Xmx2g -Xms2g' \
--set resources.limits.memory='5Gi' \
--set volumeClaimTemplate.resources.requests.storage='100Gi' \
--set volumeClaimTemplate.storageClassName='nfs-client' 


# filebeat
# 默认配置为daemonset模式，采集所有节点的容器日志。
# extraVolime为容器日志在节点上的存储路径
helm upgrade --install filebeat elastic/filebeat \
--version=7.17.3 -f values.yaml \
--set daemonset.hostNetworking='true' \
--set extraVolumes[0].name='dokcerdata' \
--set extraVolumes[0].hostPath.path='/data/docker' \
--set extraVolumeMounts[0].name='dokcerdata' \
--set extraVolumeMounts[0].mountPath='/data/docker' \
--set extraVolumeMounts[0].readOnly='true' \
--set extraVolumes[1].name='log-center' \
--set extraVolumes[1].persistentVolumeClaim.claimName='log-center-pvc' \
--set extraVolumeMounts[1].name='log-center' \
--set extraVolumeMounts[1].mountPath='/tmp' -n loki
#TODO: 针对容器内的日志文件，使用sidecar将filebeat注入业务容器以采集日志

# kibana
helm install kibana elastic/kibana \
--version 7.17.3 \
--set ingress.enabled='true' \
--set ingress.hosts[0].host='kb.local.domain' \
--set ingress.hosts[0].paths[0].path='/'  
```


filebeat配置参考[filebeat.yml](filebeat.yml)


- logstash

[logstash-values.yaml](logstash-values.yaml)

```shell
helm upgrade --install logstash elastic/logstash --version 7.17.3 \
-n loki \
-f logstash-values.yaml
```