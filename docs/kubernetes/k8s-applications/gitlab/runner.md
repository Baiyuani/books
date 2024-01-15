---
tags:
  - gitlab
  - runner
---

## [安装runner](https://docs.gitlab.com/charts/charts/gitlab/gitlab-runner/)

> 20240111

[官方文档](https://docs.gitlab.com/runner/install/kubernetes.html)

[gitlab-runner-values.yaml](manifests/gitlab-runner-values.yaml)

```shell
helm repo add gitlab https://charts.gitlab.io
helm search repo -l gitlab/gitlab-runner

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
--set rbac.create=true

# 标记构建节点，仅允许构建在满足条件的节点运行
kubectl label node <nodeName> node-role.kubernetes.io/gitlab=runner
kubectl taint nodes <node-name> node-role.kubernetes.io/gitlab=runner:NoSchedule
```

