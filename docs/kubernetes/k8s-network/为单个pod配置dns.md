
## Pod 的 DNS 配置 

> 特性状态： Kubernetes v1.14 [stable]

Pod 的 DNS 配置可让用户对 Pod 的 DNS 设置进行更多控制。

!!! note 

    dnsConfig 字段是可选的，它可以与任何 dnsPolicy 设置一起使用。 但是，当 Pod 的 dnsPolicy 设置为 "None" 时，必须指定 dnsConfig 字段。

用户可以在 dnsConfig 字段中指定以下属性：

- nameservers：将用作于 Pod 的 DNS 服务器的 IP 地址列表。 最多可以指定 3 个 IP 地址。当 Pod 的 dnsPolicy 设置为 "None" 时， 列表必须至少包含一个 IP 地址，否则此属性是可选的。 所列出的服务器将合并到从指定的 DNS 策略生成的基本名称服务器，并删除重复的地址。

- searches：用于在 Pod 中查找主机名的 DNS 搜索域的列表。此属性是可选的。 指定此属性时，所提供的列表将合并到根据所选 DNS 策略生成的基本搜索域名中。 重复的域名将被删除。Kubernetes 最多允许 32 个搜索域。

- options：可选的对象列表，其中每个对象可能具有 name 属性（必需）和 value 属性（可选）。 此属性中的内容将合并到从指定的 DNS 策略生成的选项。 重复的条目将被删除。

以下是具有自定义 DNS 设置的 Pod 示例：

```yaml
apiVersion: v1
kind: Pod
metadata:
  namespace: default
  name: dns-example
spec:
  containers:
    - name: test
      image: nginx
  dnsPolicy: "None"
  dnsConfig:
    nameservers:
      - 192.0.2.1 # 这是一个示例
    searches:
      - ns1.svc.cluster-domain.example
      - my.dns.search.suffix
    options:
      - name: ndots
        value: "2"
      - name: edns0
```

