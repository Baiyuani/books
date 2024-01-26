---
tags:
  - go
  - k8s
  - k8s-operator
---

## [限制所有控制器将监视资源的命名空间](https://book.kubebuilder.io/cronjob-tutorial/empty-main)

`cmd/main.go:main()`

```go 
    mgr, err := ctrl.NewManager(ctrl.GetConfigOrDie(), ctrl.Options{
        Scheme: scheme,
        Cache: cache.Options{
            DefaultNamespaces: map[string]cache.Config{
                namespace: {},
            },
        },
        Metrics: server.Options{
            BindAddress: metricsAddr,
        },
        WebhookServer:          webhook.NewServer(webhook.Options{Port: 9443}),
        HealthProbeBindAddress: probeAddr,
        LeaderElection:         enableLeaderElection,
        LeaderElectionID:       "80807133.tutorial.kubebuilder.io",
    })
```

## [支持旧集群版本](https://book.kubebuilder.io/reference/generating-crd#supporting-older-cluster-versions)

https://book.kubebuilder.io/cronjob-tutorial/new-api

与 Go API 类型一起创建的默认 CustomResourceDefinition 清单使用 API version v1。如果您的项目打算支持早于 v1.16 的 Kubernetes 集群版本，则必须 从Makefile 变量中设置--crd-version v1beta1

