# 部署


> 参考文档：https://kubernetes.io/zh/docs/tasks/access-application-cluster/web-ui-dashboard/

[recommended.yaml](recommended.yaml)

```bash
#如果无法访问可以配置host：https://github.com/ineo6/hosts
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.2.0/aio/deploy/recommended.yaml

#将服务设置为nodeport，实现在windows跳板机访问
kubectl edit svc -n kubernetes-dashboard kubernetes-dashboard

#dashboard创建用户，生成token
kubectl create sa dashboard-admin -n kube-system

#给用户绑定角色
kubectl create clusterrolebinding dashboard-admin --clusterrole=cluster-admin --serviceaccount=kube-system:dashboard-admin

#查看用户的token：
kubectl describe secrets -n kube-system $(kubectl -n kube-system get secret | awk '/dashboard-admin/{print $1}')
```

访问地址：https://192.168.0.111:30849
使用token登录dashboard  
