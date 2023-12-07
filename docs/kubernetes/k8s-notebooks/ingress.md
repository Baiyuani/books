# ingress-nginx

## ingress-nginx 代理外部域名

```yaml
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
#    nginx.ingress.kubernetes.io/backend-protocol: HTTPS
    nginx.ingress.kubernetes.io/rewrite-target: /$2
    nginx.ingress.kubernetes.io/upstream-vhost: prometheus.baiyuani.top
    nginx.ingress.kubernetes.io/use-regex: "true"
  name: test
  namespace: dev
spec:
  ingressClassName: nginx
  rules:
  - host: test.baiyuani.top
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
#    - 'test.baiyuani.top'
#    secretName: domain-tls

---
apiVersion: v1
kind: Service
metadata:
  name: test
  namespace: dev
spec:
  externalName: prometheus.baiyuani.top
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
