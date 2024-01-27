---
tags:
  - go
  - k8s
  - k8s-operator
---

# [初始化项目](https://book.kubebuilder.io/quick-start)

- 环境准备
    ```
    go version v1.20.0+
    docker version 17.03+.
    kubectl version v1.11.3+.
    Access to a Kubernetes v1.11.3+ cluster.
    ```

```shell
sudo apt install make
```

- 安装kubebuilder

```shell
# download kubebuilder and install locally.
curl -L -o kubebuilder "https://go.kubebuilder.io/dl/latest/$(go env GOOS)/$(go env GOARCH)"
chmod +x kubebuilder && mv kubebuilder /usr/local/bin/

# 命令行补全
cat << 'EOF' >> ~/.bashrc
# kubebuilder autocompletion
if [ -f /usr/local/share/bash-completion/bash_completion ]; then
. /usr/local/share/bash-completion/bash_completion
fi
. <(kubebuilder completion bash)
EOF
```

- 创建项目

```shell
KB_PROJECT="test-app"
KB_DOMAIN="baiyuani.top"

mkdir -p ~/projects/${KB_PROJECT}
cd ~/projects/${KB_PROJECT}
kubebuilder init --domain ${KB_DOMAIN} --repo ${KB_DOMAIN}/${KB_PROJECT}
```

- 创建api

```shell
kubebuilder create api --group apps --version v1alpha1 --kind Guestbook

# 使用deploy-image/v1-alpha插件
kubebuilder create api \
--group apps \
--version v1alpha1 \
--kind SshTunnel \
--image=synin/ssh:latest \
--image-container-command="ssh,-D,0.0.0.0:1337,-Ng,sshtunnel@gpt.xxx.com" \
--image-container-port="1337" \
--run-as-user="1001" \
--plugins="deploy-image/v1-alpha" \
--make=false
```

- 安装

```shell
# 生成
make manifests
# 安装crd
make install
# 运行
make run
```

- 创建cr

```shell
# 编辑后再执行
kubectl apply -k config/samples/
```

- 在集群中运行

```shell
make docker-build docker-push IMG=<some-registry>/<project-name>:tag
make deploy IMG=<some-registry>/<project-name>:tag
```


- 卸载

```shell
# 删除crd
make uninstall
# 卸载controller 
make undeploy
```

- 实现webhooks

https://book.kubebuilder.io/cronjob-tutorial/webhook-implementation

```shell
kubebuilder create webhook --group batch --version v1 --kind CronJob --defaulting --programmatic-validation
# 与 Go webhook 实现一起创建的默认 WebhookConfiguration 清单使用 API version v1。如果您的项目打算支持 v1.16 之前的 Kubernetes 集群版本，请设置--webhook-version v1beta1
```

```shell
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set installCRDs=true \
  --set prometheus.enabled=false \
  --set webhook.timeoutSeconds=10 \
  --set ingressShim.defaultIssuerName=letsencrypt-prod \
  --set ingressShim.defaultIssuerKind=ClusterIssuer \
  --set ingressShim.defaultIssuerGroup=cert-manager.io
```
