```shell
helm template oceanbase-test ketanyun-stable/helper -n oceanbase-test \
--create-namespace \
--set image.repository='oceanbase/oceanbase-ce' \
--set env.MINI_MODE=1 \
--set updateStrategy.type='Recreate' \
--set containerPorts.http='2881' \
--set service.ports.http='2881' \
--set persistence.enabled=true \
--set persistence.mountPath='/root/ob' \
--set persistence.storageClass='local-path' \
--set persistence.accessModes[0]='ReadWriteOnce' \
--set persistence.size='40Gi' \
--set nodeSelector.'kubernetes\.io/hostname'=k8s-node2 \
--set-string resources.limits.cpu='2' \
--set resources.limits.memory='4Gi' \
--set-string resources.requests.cpu='500m' \
--set resources.requests.memory='1Gi' \
--set service.type='NodePort' 
```

```yaml
---
# Source: helper/templates/pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: oceanbase-test-pvc
  namespace: oceanbase-test
  labels:
    app.kubernetes.io/name: helper
    helm.sh/chart: helper-1.0.5
    app.kubernetes.io/instance: oceanbase-test
    app.kubernetes.io/managed-by: Helm
  annotations:
spec:
  accessModes:
    - "ReadWriteOnce"
  resources:
    requests:
      storage: 40Gi
  storageClassName: local-path
  volumeMode: Filesystem
---
# Source: helper/templates/pvc2.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: oceanbase-test-metadata-pvc
  namespace: oceanbase-test
  labels:
    app.kubernetes.io/name: helper
    helm.sh/chart: helper-1.0.5
    app.kubernetes.io/instance: oceanbase-test
    app.kubernetes.io/managed-by: Helm
  annotations:
spec:
  accessModes:
    - "ReadWriteOnce"
  resources:
    requests:
      storage: 10Gi
  storageClassName: local-path
  volumeMode: Filesystem
---
# Source: helper/templates/pvc3.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: oceanbase-test-agent-pvc
  namespace: oceanbase-test
  labels:
    app.kubernetes.io/name: helper
    helm.sh/chart: helper-1.0.5
    app.kubernetes.io/instance: oceanbase-test
    app.kubernetes.io/managed-by: Helm
  annotations:
spec:
  accessModes:
    - "ReadWriteOnce"
  resources:
    requests:
      storage: 20Gi
  storageClassName: local-path
  volumeMode: Filesystem
---
# Source: helper/templates/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: oceanbase-test
  namespace: oceanbase-test
  labels:
    helm.sh/chart: helper-1.0.5
    app.kubernetes.io/name: helper
    app.kubernetes.io/instance: oceanbase-test
    app.kubernetes.io/version: "0.1.0"
    app.kubernetes.io/managed-by: Helm
spec:
  ports:
    - name: http
      port: 2881
      targetPort: http
  selector:
    app.kubernetes.io/name: helper
    app.kubernetes.io/instance: oceanbase-test
  sessionAffinity: None
  type: NodePort
---
# Source: helper/templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: oceanbase-test
  namespace: oceanbase-test
  labels:
    helm.sh/chart: helper-1.0.5
    app.kubernetes.io/name: helper
    app.kubernetes.io/instance: oceanbase-test
    app.kubernetes.io/version: "0.1.0"
    app.kubernetes.io/managed-by: Helm
spec:
  minReadySeconds: 0
  progressDeadlineSeconds: 600
  revisionHistoryLimit: 10
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app.kubernetes.io/name: helper
      app.kubernetes.io/instance: oceanbase-test
  replicas: 1
  template:
    metadata:
      labels:
        app.kubernetes.io/name: helper
        app.kubernetes.io/instance: oceanbase-test
      annotations:
    spec:
      
      automountServiceAccountToken: false
      affinity:
        podAffinity:
          
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
            - podAffinityTerm:
                labelSelector:
                  matchLabels:
                    app.kubernetes.io/name: helper
                    app.kubernetes.io/instance: oceanbase-test
                namespaces:
                  - "oceanbase-test"
                topologyKey: kubernetes.io/hostname
              weight: 1
        nodeAffinity:
          
      nodeSelector:
        kubernetes.io/hostname: k8s-node2
      containers:
        - name: oceanbase-test
          image: oceanbase/oceanbase-ce
          imagePullPolicy: IfNotPresent
          env:


            - name: MODE
              value: "slim"

          envFrom:



          ports:
            - containerPort: 2881
              name: http
              protocol: TCP
          resources: {}
          volumeMounts:
            - name: oceanbase-test-pvc
              mountPath: /root/ob
            - name: oceanbase-test-metadata-pvc
              mountPath: /root/.obd
            - name: oceanbase-test-agent-pvc
              mountPath: /root/obagent
      volumes:
        - name: oceanbase-test-pvc
          persistentVolumeClaim:
            claimName: oceanbase-test-pvc
        - name: oceanbase-test-metadata-pvc
          persistentVolumeClaim:
            claimName: oceanbase-test-metadata-pvc
        - name: oceanbase-test-agent-pvc
          persistentVolumeClaim:
            claimName: oceanbase-test-agent-pvc
      restartPolicy: Always
      terminationGracePeriodSeconds: 60
      dnsPolicy: ClusterFirst

```