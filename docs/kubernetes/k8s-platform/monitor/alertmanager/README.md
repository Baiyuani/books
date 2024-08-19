## 创建alertmanager配置

- [alertmanagerconfig.yaml](alertmanagerconfig.yaml)

```shell
kubectl create secret generic alertmanagerconfig-receiver-wechat-apisecret -n ops \
--from-literal=secret=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

kubectl apply -f alertmanagerconfig.yaml
```

该方式添加的配置默认添加所在命名空间的matchers
```yaml
    matchers:
    - namespace="ops"
```
全局配置可以配置`helm values: alertmanager.config`

## 配置文件示例

- [alertmanager.yaml](alertmanager.yaml)

## 消息模板

- [templates](templates)

## 部署企微群机器人adapter

[webhook-adapter.yaml](manifests/webhook-adapter.yaml)
