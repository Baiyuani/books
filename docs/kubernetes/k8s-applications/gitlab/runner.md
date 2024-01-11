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

# appVersion: 16.7.0
helm install gitlab-runner -f gitlab-runner-values.yaml gitlab/gitlab-runner \
--create-namespace --namespace <NAMESPACE> \
--version 0.60.0 \
--set runnerToken='' \
--set gitlabUrl=https://gitlab.example.com 
```

