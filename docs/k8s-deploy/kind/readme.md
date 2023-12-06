

## kind 搭建测试环境

```shell
kind create cluster --config=config-with-port-mapping.yaml --image=kindest/node:v1.19.16
kind create cluster --config=config-with-port-mapping.yaml --image=kindest/node:v1.24.15
```