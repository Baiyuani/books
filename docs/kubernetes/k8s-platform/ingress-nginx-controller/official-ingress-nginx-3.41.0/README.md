# 官方 3.41.0


> github： https://github.com/kubernetes/ingress-nginx     \
> 部署文档： https://kubernetes.github.io/ingress-nginx/deploy/    \
> charts:  https://github.com/kubernetes/ingress-nginx/tree/main/charts/ingress-nginx  \


#### Prerequisites
Chart version 3.x.x: Kubernetes v1.16+


#### 安装

```bash
# yaml方式部署
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.51.0/deploy/static/provider/cloud/deploy.yaml
```

```bash
# helm方式部署
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx --timeout 20m0s \
--version 3.41.0 \
--namespace ingress-nginx --create-namespace  \
--set controller.image.image='nginx-ingress-controller' \
--set controller.image.registry='registry.aliyuncs.com/google_containers' \
--set controller.admissionWebhooks.patch.image.image='kube-webhook-certgen' \
--set controller.admissionWebhooks.patch.image.registry='registry.aliyuncs.com/google_containers' \
--set controller.kind=DaemonSet  \
--set controller.dnsPolicy=ClusterFirstWithHostNet  \
--set controller.hostNetwork=true  \
--set controller.ingressClassResource.enabled=true  \
--set controller.ingressClassResource.default=true  \
--set controller.config.log-format-upstream='$remote_addr - $remote_user [$time_local] "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent" $request_length $request_time [$proxy_upstream_name] [$proxy_alternative_upstream_name] $upstream_addr $upstream_response_length $upstream_response_time $upstream_status $req_id $http_x_correlation_id' \
--set controller.config.enable-underscores-in-headers='true' \
--set controller.config.max-worker-connections='65531' \
--set controller.config.server-tokens='false'  \
--set controller.config.use-gzip="true" \
--set controller.config.ssl-redirect="false"


# 开启prometheus metrics
--set controller.metrics.enabled=true \
--set controller.metrics.serviceMonitor.enabled=true \

# configmap参数
--set controller.config.access-log-path='/var/log/ingress/access.log'  \
--set controller.config.error-log-path='/var/log/ingress/error.log'  \
--set controller.config.log-format-upstream='{"@timestamp": "$time_iso8601","remote_addr": "$remote_addr","x-forward-for": "$proxy_add_x_forwarded_for","request_id": "$req_id","remote_user": "$remote_user","bytes_sent": $bytes_sent,"request_time": $request_time,"status": $status,"vhost": "$host","request_proto": "$server_protocol","path": "$uri","request_query": "$args","request_length": $request_length,"duration": $request_time,"method": "$request_method","http_referrer": "$http_referer","http_user_agent": "$http_user_agent","upstream-sever":"$proxy_upstream_name","proxy_alternative_upstream_name":"$proxy_alternative_upstream_name","upstream_addr":"$upstream_addr","upstream_response_length":$upstream_response_length,"upstream_response_time":$upstream_response_time,"upstream_status":$upstream_status}'  \
--set controller.config.use-forwarded-headers="true"  \
--set controller.config.enable-underscores-in-headers='true' \
--set controller.config.http-redirect-code='301'   \
--set controller.config.max-worker-connections='65531' \
--set controller.config.proxy-body-size=100m  \
--set controller.config.proxy-read-timeout='720'   \
--set controller.config.server-tokens='false'  \
--set controller.config.ssl-protocols="TLSv1 TLSv1.1 TLSv1.2 TLSv1.3"  \
--set controller.config.use-gzip="true" 
```


