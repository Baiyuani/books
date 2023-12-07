# helm部署(bitnami)

##  loki一体化包，包含promtail

> [charts仓库地址](https://github.com/bitnami/charts/tree/5504d8dd3e500a7c97d3f9c2d2becbcc89b8d53f/bitnami/grafana-loki)
> 


```shell
helm repo add bitnami https://charts.bitnami.com/bitnami

helm upgrade --install grafana-loki bitnami/grafana-loki -n loki 

# loki对接grafana
# https://grafana.com/docs/loki/latest/operations/grafana/
```
