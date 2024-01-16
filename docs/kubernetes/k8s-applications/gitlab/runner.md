---
tags:
  - gitlab
  - runner
---

## [部署gitlab-runner](https://docs.gitlab.com/charts/charts/gitlab/gitlab-runner/)

> 20240111

[官方文档](https://docs.gitlab.com/runner/install/kubernetes.html)

[gitlab-runner-values.yaml](manifests/gitlab-runner-values.yaml)


### 创建cd用的service account

```shell
kubectl create sa -n gitlab gitlab-cd
```

#### 授权(优先使用方法2)

1. 授权集群管理员权限（不建议，有集群安全风险）
    ```shell
    NS=gitlab
    kubectl create clusterrolebinding gitlab-cd-${NS}-cluster-admin --clusterrole=cluster-admin --serviceaccount=${NS}:gitlab-cd
    unset NS
    ```

2. 自定义权限（建议，仅授权必须的权限，可后期动态调整）
    ```shell
    NS=gitlab
    kubectl -n ${NS} apply -f gitlab-cd-clusterrole.yaml
    kubectl create clusterrolebinding gitlab-cd-${NS}-cluster-permission --clusterrole=gitlab-cd --serviceaccount=${NS}:gitlab-cd
    unset NS
    ```

[gitlab-cd-clusterrole.yaml](manifests%2Fgitlab-cd-clusterrole.yaml)

### 安装

```shell
helm repo add gitlab https://charts.gitlab.io
helm search repo -l gitlab/gitlab-runner

# 将minio链接密钥保存到secret
kubectl create secret generic runner-minio-access \
    -n gitlab \
    --from-literal=accesskey="GbbNXEe1c2s1hj9srvWp" \
    --from-literal=secretkey="pEhzoHydH3zEYPVO7NEsXsHznHy4lfJvkuNqJTrn"

# runnerToken从gitlab页面，创建runner时获取
# appVersion: 16.7.0
helm upgrade --install gitlab-runner -f gitlab-runner-values.yaml gitlab/gitlab-runner \
--create-namespace --namespace gitlab \
--version 0.60.0 \
--set runnerToken='' \
--set gitlabUrl=https://gitlab.example.com \
--set image.registry='docker.io' \
--set image.image='gitlab/gitlab-runner' \
--set image.tag='v16.7.0' \
--set runners.cache.secretName='runner-minio-access' \
--set rbac.create=true \
--set podSecurityContext.runAsUser=999 \
--set podSecurityContext.fsGroup=999 



# 标记构建节点，仅允许构建在满足条件的节点运行
kubectl label node <nodeName> node-role.kubernetes.io/gitlab=runner
kubectl taint nodes <node-name> node-role.kubernetes.io/gitlab=runner:NoSchedule
```

