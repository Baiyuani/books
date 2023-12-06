##

如果需要配置tidb主从同步，移步[tidb数据同步](./tidb数据同步.md)

#### [tidb-cluster.yaml](./manifests/tidb-cluster.yaml)中打开pump组件即自动开启binlog，

```yaml
  ## Deploy TiDB Binlog of a TiDB cluster
  ## Ref: https://docs.pingcap.com/tidb-in-kubernetes/stable/deploy-tidb-binlog/#deploy-pump
  pump:
  #   baseImage: pingcap/tidb-binlog
  #   version: "v6.5.0"
    replicas: 3
    storageClassName: local-path
    requests:
  #     cpu: 1000m
  #     memory: 1Gi
      storage: 10Gi
  #   limits:
  #     cpu: 2000m
  #     memory: 2Gi
  #   imagePullPolicy: IfNotPresent
  #   imagePullSecrets:
  #   - name: secretName
  #   hostNetwork: false
  #   serviceAccount: advanced-tidb-pump
  #   priorityClassName: system-cluster-critical
  #   schedulerName: default-scheduler
  #   nodeSelector:
  #     app.kubernetes.io/component: pump
  #   annotations:
  #     node.kubernetes.io/instance-type: some-vm-type
  #   tolerations: {}
  #   configUpdateStrategy: RollingUpdate
  #   statefulSetUpdateStrategy: RollingUpdate
  #   podSecurityContext: {}
  #   env: []
  #   additionalContainers: []
  #   additionalVolumes: []
  #   additionalVolumeMounts: []
  #   terminationGracePeriodSeconds: 30
  #   # Ref: https://docs.pingcap.com/tidb/stable/tidb-binlog-configuration-file#pump
  #   config: |
  #     gc = 7
  #   # TopologySpreadConstraints for pod scheduling, will overwrite cluster level spread constraints setting
  #   # Ref: pkg/apis/pingcap/v1alpha1/types.go#TopologySpreadConstraint
  #   topologySpreadConstraints:
  #   - topologyKey: topology.kubernetes.io/zone

```