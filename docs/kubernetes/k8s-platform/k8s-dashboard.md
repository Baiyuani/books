# Kubernetes 仪表板（Dashboard）

> 参考文档：https://kubernetes.io/zh/docs/tasks/access-application-cluster/web-ui-dashboard/

## 部署

```shell
# 添加 kubernetes-dashboard 仓库
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
# 使用 kubernetes-dashboard Chart 部署名为 `kubernetes-dashboard` 的 Helm Release
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard \
--create-namespace --namespace kubernetes-dashboard \
--set app.ingress.enabled=true \
--set app.ingress.hosts[0]=k8s-dashboard.local.domain \
--set app.ingress.ingressClassName=nginx
```


## 使用

- [Creating sample user](https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md)

```bash
#dashboard创建用户，生成token
kubectl create sa admin-user -n kubernetes-dashboard

#给用户绑定角色
kubectl create clusterrolebinding admin-user --clusterrole=cluster-admin --serviceaccount=kubernetes-dashboard:admin-user

#查看用户的token：
kubectl -n kubernetes-dashboard create token admin-user
```
