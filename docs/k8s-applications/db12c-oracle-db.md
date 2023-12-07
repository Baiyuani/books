

## 使用oracle账号创建镜像拉取密钥



```shell
kubectl create secret docker-registry oracle-office-zhdong -n $NS \
--docker-username= \
--docker-password='' \
--docker-server=container-registry.oracle.com  \
--dry-run=client -o yaml | kubectl apply -f -
```
   


## 创建数据卷
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: db12c-oracle-db
  namespace: ketanyun
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 30Gi
  storageClassName: nfs-client
  volumeMode: Filesystem
```

## 设置oracle密码

```shell
kubectl create secret generic db12c-oracle-db -n ketanyun \
--from-literal=oracle_pwd='' \
--dry-run=client -o yaml | kubectl apply -f -
```

## 部署

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  annotations:
    description: Oracle db12c
  labels:
    k8s-app: db12c-oracle-db
    qcloud-app: db12c-oracle-db
  name: db12c-oracle-db
  namespace: ketanyun
spec:
  serviceName: db12c-oracle-db
  podManagementPolicy: OrderedReady
  replicas: 1
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      k8s-app: db12c-oracle-db
      qcloud-app: db12c-oracle-db
  updateStrategy:
    rollingUpdate:
      partition: 0
    type: RollingUpdate
  template:
    metadata:
      labels:
        k8s-app: db12c-oracle-db
        qcloud-app: db12c-oracle-db
    spec:
      containers:
      - env:
        - name: DB_SID
          value: ORCL
        - name: DB_PDB
          value: prod
        - name: DB_PASSWD
          valueFrom:
            secretKeyRef:
              key: oracle_pwd
              name: db12c-oracle-db
              optional: false
        - name: DB_DOMAIN
          value: local
        - name: DB_MEMORY
          value: 2Gi
        - name: DB_BUNDLE
          value: basic
        image: container-registry.oracle.com/database/enterprise:12.2.0.1
        imagePullPolicy: IfNotPresent
        name: oracle-db
        ports:
        - containerPort: 1521
          protocol: TCP
        readinessProbe:
          exec:
            command:
            - /bin/sh
            - -c
            - /home/oracle/setup/healthcheck.sh
          failureThreshold: 3
          initialDelaySeconds: 360
          periodSeconds: 40
          successThreshold: 1
          timeoutSeconds: 20
        resources:
          limits:
            cpu: "2"
            memory: 4Gi
          requests:
            cpu: 500m
            memory: 1Gi
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        volumeMounts:
        - mountPath: /dev/shm
          name: dshm
        - mountPath: /ORCL
          name: db12c-oracle-db
      dnsPolicy: ClusterFirst
      imagePullSecrets:
      - name: oracle-office-zhdong
      restartPolicy: Always
      securityContext:
        fsGroup: 54321
        runAsUser: 54321
      terminationGracePeriodSeconds: 30
      volumes:
      - emptyDir:
          medium: Memory
        name: dshm
#      - name: datamount
#        persistentVolumeClaim:
#          claimName: db12c-oracle-db
  volumeClaimTemplates:
  - metadata:
      name: db12c-oracle-db
    spec:
      accessModes:
      - ReadWriteOnce
      resources:
        requests:
          storage: 200Gi
      storageClassName: nfs-client

---

apiVersion: v1
kind: Service
metadata:
  annotations:
    description: Oracle db12c
  name: db12c-oracle-db
  namespace: ketanyun
spec:
  ports:
  - name: tcp-1521
    port: 1521
    protocol: TCP
    targetPort: 1521
  selector:
    k8s-app: db12c-oracle-db
    qcloud-app: db12c-oracle-db
  sessionAffinity: None
  type: ClusterIP
```