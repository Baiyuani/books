# kubectl常用命令

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
