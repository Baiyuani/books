# coredns

## coredns配置泛域名hosts

```shell
apiVersion: v1
data:
  Corefile: |
    .:53 {
        errors
        health {
           lameduck 5s
        }
        ready
        hosts {
           192.168.0.204 kas.baiyuani.top minio.baiyuani.top registry.baiyuani.top gitlab.baiyuani.top harbor.baiyuani.top
           fallthrough
        }
        template IN A dzh.com {
          match .*\.dzh\.com
          answer "{{ .Name }} 60 IN A 192.168.1.1"
          fallthrough
        }
        kubernetes cluster.local in-addr.arpa ip6.arpa {
           pods insecure
           fallthrough in-addr.arpa ip6.arpa
           ttl 30
        }
        prometheus :9153
        forward . /etc/resolv.conf {
           max_concurrent 1000
        }
        cache 30
        loop
        reload
        loadbalance
    }
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
```

## coredns 配置dns
```yaml
apiVersion: v1
data:
  Corefile: |
    .:53 {
        errors
        health {
           lameduck 5s
        }
        ready
        hosts {
           192.168.110.183 my-sso.saif.sjtu.edu.cn
           fallthrough
        }
        kubernetes cluster.local in-addr.arpa ip6.arpa {
           pods insecure
           fallthrough in-addr.arpa ip6.arpa
           ttl 30
        }
        prometheus :9153
        forward . /etc/resolv.conf {
           max_concurrent 1000
        }
        cache 30
        loop
        reload
        loadbalance
    }
    saifdc1.saif.com:53 {
      errors
      cache 30
      forward . 172.16.110.11
      reload
    }
    saifdc2.saif.com:53 {
      errors
      cache 30
      forward . 172.16.110.12
      reload
    }
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system

```
