## 修改报错页面，防止泄露服务器信息

可以参照[官方](https://kubernetes.github.io/ingress-nginx/examples/customization/custom-errors/)的文档说明，配置流程如下。

[custom-default-backend.yaml](custom-default-backend.yaml)


### 1. 部署默认后端
```shell
kubectl -n ingress-nginx create -f custom-default-backend.yaml


kubectl get deploy,svc -n ingress-nginx
NAME                           DESIRED   CURRENT   READY     AGE
deployment.apps/nginx-errors   1         1         1         10s
 
NAME                   TYPE        CLUSTER-IP  EXTERNAL-IP   PORT(S)   AGE
service/nginx-errors   ClusterIP   10.0.0.12   <none>        80/TCP    10s
```


### 2. 配置启动参数
修改Ingress controller控制器的启动参数，加入以下配置，通过--default-backend标志的值设置为新创建的错误后端的名称，注意将重启ingress controller


```shell
kubectl -n ingress-nginx edit ds nginx-ingress-controller
    spec:
      containers:
      - args:
        - /nginx-ingress-controller
        - --configmap=$(POD_NAMESPACE)/nginx-configuration
        - --tcp-services-configmap=$(POD_NAMESPACE)/tcp-services
        - --udp-services-configmap=$(POD_NAMESPACE)/udp-services
        - --publish-service=$(POD_NAMESPACE)/ingress-nginx
        - --annotations-prefix=nginx.ingress.kubernetes.io
        - --default-backend-service=ingress-nginx/nginx-errors  # 添加此行
```

### 3. 修改configmap
修改对应的configmap指定要关联到默认后端服务的服务状态码，意味着如果状态码是配置项中的值，那么返回给客户端浏览器的就是默认后端服务

```shell
kubectl -n ingress-nginx edit configmap nginx-configuration
data:
  custom-http-errors: 403,404,500,502,503,504 # 添加此行
```


### 4. 测试
通过终端命令访问上面404和503页面的两个域名
```shell
curl example.bar.com/asdasdasd                         
5xx html                                                                                                                                                                        #  ingress-nginx curl example.foo.com                              
<span>The page you're looking for could not be found.</span>
#  自定义Accept标头
#  ingress-nginx curl -H 'Accept: application/json' example.foo.com
{ "message": "The page you're looking for could not be found" }
可以看到默认后端将404状态码返回了字符串，503返回了5xx html的字符串。缺点在于这样的情况如果用浏览器进行访问，仅仅是一个字符串文本甚至无法正常显示，因此需要重新定义这个默认后端服务，提供友好的界面返回。

```


### 5. [深度定制 Kubernetes Nginx Ingress 错误提示页面](https://blog.csdn.net/easylife206/article/details/111878377)
