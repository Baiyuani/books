# 通过pvc持久化容器内日志文件

## 配置

### 1. 配置服务
```bash
#存储服务器安装nfs服务
yum -y install nfs-utils

#在存储服务器中，创建挂载目录
mkdir -p /data/logs

vim /etc/exports
/data/kubernetes 192.168.0.0/24(rw,async,no_root_squash)
/data/logs 192.168.0.0/24(rw,async,no_root_squash)

exportfs -arv && showmount -e 

#配置日志自动归档清理脚本
chmod +x log_auto_handle.sh
(crontab -l; echo '0 3 * * * log_auto_handle.sh &> /dev/null') | crontab     #实际配置时需要绝对路径
```

### 2. 部署
```bash
# https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner/tree/master/charts/nfs-subdir-external-provisioner
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
helm repo update
helm install nfs-client-log nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
-n nfs-client-provisioner --create-namespace \
--set image.repository=willdockerhub/nfs-subdir-external-provisioner \
--set image.tag=v4.0.2 \
--set nfs.server=192.10.86.7 \
--set nfs.path=/data/nfs_data \
--set storageClass.name=nfs-client-log \
--set storageClass.defaultClass=true 
```


### 3.应用配置(java)

[deploy-log-pvc.yaml](deploy-log-pvc.yaml)

```yaml
      - env:
        - name: JAVA_TOOL_OPTIONS
          value: "-Xmx1600m -Xms800m"
        - name: SPRING_APPLICATION_JSON
          value: '{"server":{"tomcat.accesslog":{"directory":"/apps/logs","enabled":"true","prefix":"accesslog","suffix":".txt","pattern":"%{org.apache.catalina.AccessLog.RemoteAddr}r %h %{tenantUserId}s %{JSESSIONID}c %S %{[yyyy-MM-dd HH:mm:ss.S]}t %m &quot;%U&quot; &quot;%q&quot; %s %b %D &quot;%{Referer}i&quot; &quot;%{User-Agent}i&quot;"}}}'

        resources:
          limits:
            cpu: 1000m
            memory: 2Gi
          requests:
            cpu: 100m
            memory: 512Mi

        volumeMounts:
        - mountPath: /apps/logs
          name: deploy-log
      volumes:
        - name: deploy-log
          persistentVolumeClaim:
            claimName: deploy-log
            
#statefulset
  volumeClaimTemplates:   
  - metadata:
      name: sts-log
    spec: 
      accessModes: 
      - ReadWriteMany
      resources: 
        requests: 
          storage: 20Gi
      storageClassName: nfs-client-log

```


### 4.特殊应用
```yaml
#infoplus
        volumeMounts:
        - mountPath: /usr/local/tomcat/logs
          name: infopluslogs
          
  volumeClaimTemplates:   
  - metadata:
      name: infopluslogs
    spec: 
      accessModes: 
      - ReadWriteOnce
      resources: 
        requests: 
          storage: 100Gi
      storageClassName: nfs-client-log
```

## 定期清理

[log_auto_handle.sh](log_auto_handle.sh)

