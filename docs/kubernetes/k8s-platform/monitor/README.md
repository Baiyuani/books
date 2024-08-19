# Prometheus

## Install

### [kube-prometheus-stack](kube-prometheus-stack)


### 单独安装

- [prometheus](prometheus) TODO

- [grafana](grafana)

- [alertmanager](alertmanager) TODO

- [kube-state-metrics.md](kube-state-metrics.md)

### Exporter

- [mysql-exporter](exporters/mysql-exporter)

- [node-exporter.md](exporters/node-exporter.md)

- [blackbox-exporter.md](exporters/blackbox-exporter)

## Configuration

### alertmanager TODO


## note

### 触发prometheus重载配置

```shell
curl -X POST http://10.102.52.14:9090/-/reload
```
