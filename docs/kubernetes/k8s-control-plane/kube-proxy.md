

## 修改kube-proxy运行模式

```shell
kubectl edit cm -n kube-system kube-proxy
```

```yaml
## 运行模式。ipvs或者iptables，默认为空（iptables）
mode: ""
```

- 修改后需要重启CNI插件

[Calico 自动检测 ipvs](https://docs.tigera.io/calico/latest/networking/configuring/use-ipvs#calico-auto-detects-ipvs-mode)

当 Calico 检测到 kube-proxy 在 IPVS 模式下运行时（安装期间或安装后），会自动激活 IPVS 支持。检测发生在 calico-node 启动时，因此如果您在正在运行的集群中更改 kube-proxy 的模式，则需要重新启动 calico-node 实例。

```shell
kubectl rollout restart ds calico-node
```

