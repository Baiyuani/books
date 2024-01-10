# ingress-nginx

## ingress-nginx不通过service转发流量，ingress中配置的serviceName仅用于匹配pod

`Internet` -> `ingress-nginx-controller` -> `pod`

验证：

1. 启动一个具备3个pod的工作负载
2. 设置该工作负载的service的`sessionAffinity: ClientIP`，即如果ingress-nginx转发时使用service，那么流量经过service时总是命中同一个pod
3. 直接访问service，验证`sessionAffinity: ClientIP`有效。
4. 通过ingress访问，验证`sessionAffinity: ClientIP`无效。即ingress直接转到pod
5. `nginx.ingress.kubernetes.io/affinity: cookie`配置后，ingress-nginx会返回给浏览器一个cookie，形如`INGRESSCOOKIE=1704864597.384.165.82687|ee780868b2b0b107ed5d4ffd0fd10be9`。ingress-nginx通过该cookie进行会话保持


## ingress-nginx 代理外部域名

```yaml
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
#    nginx.ingress.kubernetes.io/backend-protocol: HTTPS
    nginx.ingress.kubernetes.io/rewrite-target: /$2
    nginx.ingress.kubernetes.io/upstream-vhost: prometheus.site.domain
    nginx.ingress.kubernetes.io/use-regex: "true"
  name: test
  namespace: dev
spec:
  ingressClassName: nginx
  rules:
  - host: test.site.domain
    http:
      paths:
      - backend:
          service:
            name: test
            port:
              number: 80
        path: /test(/|$)(.*)
        pathType: ImplementationSpecific
#  tls:
#  - hosts:
#    - 'test.site.domain'
#    secretName: domain-tls

---
apiVersion: v1
kind: Service
metadata:
  name: test
  namespace: dev
spec:
  externalName: prometheus.site.domain
  sessionAffinity: None
  type: ExternalName

```



## ingress添加请求头


```shell

      set $X-Forwarded-Proto https;
      set $X-Forwarded-Port 443;
      set $http_x_forwarded_proto https;
      set $http_x_forwarded_port 443;



      add_header "X-XSS-Protection" "1; mode=block";
      add_header Cache-Control no-cache;
      add_header X-Frame-Options SAMEORIGIN;
      add_header Set-Cookie "HttpOnly";
      add_header Set-Cookie "Secure";
      if ($request_method !~ ^(GET|POST|PUT|OPTIONS|DELETE)$) {
            return 403;
      }


      add_header Content-Security-Policy "default-src 'self' localhost:8080 'unsafe-inline' 'unsafe-eval' blob: data: ;";
      add_header X-Content-Type-Options nosniff;
```
