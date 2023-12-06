
# 在k8s中高可用部署（失败）

https://www.oceanbase.com/docs/common-oceanbase-database-cn-1000000000218236


```shell
helm repo add ob-operator https://oceanbase.github.io/ob-operator/
helm install ob-operator ob-operator/ob-operator --namespace=oceanbase --create-namespace  --version=1.1.0
```


```shell
# 节点规划
kubectl label node k8s-node1 ob.zone=zone1
kubectl label node k8s-node2 ob.zone=zone2
kubectl label node k8s-node3 ob.zone=zone3
```

# 容器直接运行

```shell
docker run -itd -p 22881:2881 -e MODE=slim -v oceanbase:/root/ob -v oceanbase-metadata:/root/.obd -v oceanbase-agent:/root/obagent --name obstandalone oceanbase/oceanbase-ce
```

# k8s中单机部署 

[standalone.md](./standalone.md)


GRANT ALL PRIVILEGES ON *.* TO root@'%' IDENTIFIED by 'HG868yg6%E%a' WITH GRANT OPTION

