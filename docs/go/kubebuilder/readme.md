---
tags:
  - go
  - k8s
  - k8s-operator
---

## [初始化项目](https://book.kubebuilder.io/quick-start)

- 环境准备
    ```
    go version v1.20.0+
    docker version 17.03+.
    kubectl version v1.11.3+.
    Access to a Kubernetes v1.11.3+ cluster.
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
kubebuilder create api --group webapp --version v1 --kind Guestbook
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

