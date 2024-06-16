---
tags:
  - container
---

## crictl load镜像

```shell
# 查看命名空间
ctr ns ls
NAME    LABELS 
default        
k8s.io 

# k8s使用的镜像位于k8s.io中
ctr -n k8s.io images ls

# 载入镜像到k8s.io命名空间
ctr -n k8s.io images import openjdk.tar.gz 

# 查看刚载入的镜像
crictl images
```


## 根据进程PID找到对应pod

```shell
# containerd
root@tracy:~# crictl ps -q | xargs crictl inspect -o go-template --template '{{ .info.pid }}    {{ index .info.config.labels "io.kubernetes.pod.namespace" }}         {{  index .info.config.labels "io.kubernetes.pod.name" }}' 
21358    ingress-nginx         ingress-nginx-controller-r6hsw
20924    kube-system         kube-scheduler-tracy
20917    kube-system         kube-controller-manager-tracy
20592    kube-system         kube-apiserver-tracy
20557    kube-system         etcd-tracy
18969    captain-system         captain-controller-manager-5b86cdf675-j6txr
18664    captain-system         captain-chartmuseum-79d6bb79d7-fh8l4
18352    loki         grafana-7cd485b99b-4ck87
17615    loki         promtail-9hwxb
16152    loki         loki-0
15406    loki         loki-minio-647c455b5b-m9jzf
14710    loki         loki-gateway-d96bbd6bb-rpks6
14510    kube-system         metrics-server-5868f67966-72qjb
13318    nfs-client-provisioner         nfs-client-nfs-subdir-external-provisioner-fc58df597-7bmmf
12934    local-path-storage         local-path-provisioner-bf6cc89c4-6b9gb
12763    kube-system         calico-kube-controllers-7768b8dd4-jvjlv
12209    kube-system         coredns-75b8b5b69d-g842s
11954    kube-system         coredns-75b8b5b69d-fzsk5
11261    kube-system         calico-node-66tqz
8847    kube-system         kube-proxy-v8kh6


# docker
docker ps -q | xargs docker inspect -f '{{.State.Pid}}    {{ index .Config.Labels "io.kubernetes.pod.namespace" }}    {{ index .Config.Labels "io.kubernetes.pod.name" }}'
```

