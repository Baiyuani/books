curl -X POST http://10.102.52.14:9090/-/reload


## 检查metrics接口的数据格式是否正确
curl http://ketanyun-v2.ketanyun.svc.cluster.local:8080/metrics | promtool check metrics

正确的数据格式形如：
websocket{url="ws://192.168.128.6:8765"} 0
container_cpu_cfs_throttled_seconds_total{container_name="test",pod_name="test-stable",exported_namespace="demo"} 100.0
