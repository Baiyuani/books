# 日志挂载

[ingress-log-pvc.yaml](ingress-log-pvc.yaml)
[ingress-log-pv.yaml](ingress-log-pv.yaml)

## 1.ingress添加PVC用于ingress日志存储

```bash
kubectl apply -f ingress-log-pvc.yaml
#kubectl apply -f ingress-log-pv.yaml
```

## 2.ingress修改日志格式和存储位置

```shell
kubectl -n ingress-nginx edit cm ingress-nginx-controller 
```

```yaml
data: 
  access-log-path: /var/log/ingress/access.log      
  error-log-path: /var/log/ingress/error.log    
#  log-format-upstream: '{"x-forward-for": "$proxy_add_x_forwarded_for","remote_addr": "$remote_addr","@timestamp": "$time_iso8601","remote_user": "$remote_user","bytes_sent": "$bytes_sent","status": "$status","vhost": "$host","request_proto": "$server_protocol","method": "$request_method","path": "$uri","request_query": "$args","request_length": "$request_length","http_referrer": "$http_referer","http_user_agent": "$http_user_agent","upstream_response_length": "$upstream_response_length","upstream_response_time": "$upstream_response_time","upstream_status": "$upstream_status","request_time": "$request_time"}'
  log-format-upstream: '{"@timestamp": "$time_iso8601","remote_addr": "$remote_addr","x-forward-for": "$proxy_add_x_forwarded_for","request_id": "$req_id","remote_user": "$remote_user","bytes_sent": $bytes_sent,"request_time": $request_time,"status": $status,"vhost": "$host","request_proto": "$server_protocol","path": "$uri","request_query": "$args","request_length": $request_length,"duration": $request_time,"method": "$request_method","http_referrer": "$http_referer","http_user_agent": "$http_user_agent","upstream-sever":"$proxy_upstream_name","proxy_alternative_upstream_name":"$proxy_alternative_upstream_name","upstream_addr":"$upstream_addr","upstream_response_length":$upstream_response_length,"upstream_response_time":$upstream_response_time,"upstream_status":$upstream_status}'
  use-forwarded-headers: "true"
  enable-underscores-in-headers: 'true' # 支持下划线
  http-redirect-code: '301'             #301转发兼容低版本内核浏览器配置
  max-worker-connections: '65531'       #更改连接数
  proxy-body-size: 100m                  #包头大小
  proxy-read-timeout: '720'             #数据读取时间设置
  server-tokens: 'false'                #关闭nginx版本号
#  ssl-ciphers: "ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA"
#  ssl-ciphers: "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA256:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:DES-CBC3-SHA"
  ssl-protocols: "TLSv1 TLSv1.1 TLSv1.2 TLSv1.3"  #兼容TLSv1.3

```

## 3.ingress添加挂载(记得增加TZ/AsiaShanghai环境变量)
```bash
kubectl -n ingress-nginx edit daemonsets.apps ingress-nginx-controller
        - name: TZ
          value: "Asia/Shanghai"
 ......      
        volumeMounts:      
        - mountPath: /var/log/ingress      
          name: ingress-log
          readOnly: false
      ......      
      volumes:      
      - name: ingress-log    
        persistentVolumeClaim:      
          claimName: ingress-log
```

## 4.配置清理脚本

```bash
chmod +x log_auto_handle.sh
(crontab -l; echo '0 3 * * * log_auto_handle.sh &> /dev/null') | crontab

```