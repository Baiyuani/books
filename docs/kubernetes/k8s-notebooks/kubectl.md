# kubectl常用命令

## kubectl apply可能会超出请求限制。使用kubectl create或kubectl replace

apply会将包含用于创建对象的对象配置文件的内容记录在`annotations`的`kubectl.kubernetes.io/last-applied-configuration`中

    https://kubernetes.io/docs/tasks/manage-kubernetes-objects/declarative-config/#how-to-create-objects
    This sets the kubectl.kubernetes.io/last-applied-configuration: '{...}' annotation on each object. 
    The annotation contains the contents of the object configuration file that was used to create the object. 



## 配置kubectl命令行补全

```shell
source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >> ~/.bashrc
# windows
PS C:\Users\Tracy> helm completion powershell | Out-String | Invoke-Expression
PS C:\Users\Tracy> kubectl completion powershell | Out-String | Invoke-Expression

# linux
source <(helm completion bash)
helm completion bash > /etc/bash_completion.d/helm
```

## 回滚工作负载

```shell
# 查看一个工作负载的history，保留数量由revisionHistoryLimit字段决定，默认是10
kubectl -n devel rollout history sts infoplus 

# describe version
kubectl -n devel rollout history sts infoplus --revision 96

# 查看指定version的yaml
kubectl -n devel rollout history sts infoplus --revision 96 -o yaml

# 回滚到上个版本
kubectl -n devel rollout undo sts infoplus

# 回滚到指定版本
kubectl -n devel rollout undo sts infoplus --revision 96
```


## 批量解密secret的所有key

```shell
kubectl -o go-template='{{range $k,$v := .data}}{{printf "%s: " $k}}{{if not $v}}{{$v}}{{else}}{{$v | base64decode}}{{end}}{{"\n"}}{{end}}' \
get secret -n default xxx
```

## 获取podname和image

```shell
kubectl -o custom-columns=NAME:.metadata.name,IMAGE:.spec.containers[*].image \
-n devel get pods
```

## 获取workload和image

```shell
kubectl -o custom-columns=TYPE:.kind,NAME:.metadata.name,IMAGE:.spec.template.spec.containers[*].image \
get deploy,sts -n ketanyun
```

## apply目录

```shell
kubectl apply -R -f ./directory
```

## 获取nodeName字段

```shell
kubectl -o custom-columns=NAMESPACE:.metadata.namespace,NAME:.metadata.name,NODENAME:.spec.template.spec.nodeName \
get deploy,sts -A
```

## 获取workload的resources

```shell
kubectl -o custom-columns=NAME:.metadata.name,CPUREQ:.spec.template.spec.containers[0].resources.requests.cpu,CPULIMITS:.spec.template.spec.containers[0].resources.limits.cpu,MEMREQ:.spec.template.spec.containers[0].resources.requests.memory,MEMLIMITS:.spec.template.spec.containers[0].resources.limits.memory 
```

## explain 显示资源所有字段

```shell
kubectl explain deploy --recursive

kubectl explain deploy.spec.replicas
```

## kubectl events

> 是`kubectl get events`的增强，GA in v1.26.0

```shell
kubectl events -A
```

## [使用socks5代理访问集群](https://kubernetes.io/zh-cn/docs/tasks/extend-kubernetes/socks5-proxy-access-api/)

## kubectl auth

```shell
root@tracy:~# kubectl auth 
Inspect authorization.

Available Commands:
  can-i         Check whether an action is allowed
  reconcile     Reconciles rules for RBAC role, role binding, cluster role, and cluster role binding objects
  whoami        Experimental: Check self subject attributes

Usage:
  kubectl auth [flags] [options]

Use "kubectl auth <command> --help" for more information about a given command.
Use "kubectl options" for a list of global command-line options (applies to all commands).
```

## kubectl debug

> Kubernetes v1.25 [stable]
>
> 集群低版本需要修改kube-apiserver、kube-scheduler、kubelet启动配置参数，添加--feature-gates=EphemeralContainers=true
>
> 不满足要求时可以使用[nsenter](./k8s-notebooks.md#nsenter命令解决容器内部命令不足的问题)

```shell
kubectl debug $(kubectl get pod -l app=sleep -n ambient-demo -o jsonpath='{.items[0].metadata.name}') -it -n ambient-demo  --image nicolaka/netshoot  -- ss -ntlp

kubectl debug $(kubectl get pod -l app=sleep -n ambient-demo -o jsonpath='{.items[0].metadata.name}') -it --image gcr.io/istio-release/base --profile=netadmin -n ambient-demo -- iptables-save
```

## kubectl logs 

```shell
# 查看pod日志
kubectl logs ${POD_NAME}
# 查看workload日志
kubectl logs deploy/${DEPLOYMENT_NAME}
# 获取有指定labels的pods的日志
kubectl logs -l ${LABELS}

-f [mum] # tail
-p  # 获取pod的前一个容器的日志
```
