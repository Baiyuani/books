
## 基于 CEL 的 CRD 规则校验

[参考](https://moelove.info/2023/12/10/Kubernetes-v1.29-%E6%96%B0%E7%89%B9%E6%80%A7%E4%B8%80%E8%A7%88/#kep-2876-%E5%9F%BA%E4%BA%8E-cel-%E7%9A%84-crd-%E8%A7%84%E5%88%99%E6%A0%A1%E9%AA%8C%E6%AD%A3%E5%BC%8F%E8%BE%BE%E5%88%B0-ga)

在 Kubernetes v1.29 版本中基于 CEL 的 CRD 校验能力达到 GA，只需要使用 x-kubernetes-validations 定义校验规则即可

```yaml
---
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  annotations:
    controller-gen.kubebuilder.io/version: v0.13.0
  name: kongplugins.configuration.konghq.com
spec:
  group: configuration.konghq.com
  scope: Namespaced
  versions:
    name: v1
    schema:
      openAPIV3Schema:
        description: KongPlugin is the Schema for the kongplugins API.
        properties:
          plugin:
        ...
        x-kubernetes-validations:
        - message: Using both config and configFrom fields is not allowed.
          rule: '!(has(self.config) && has(self.configFrom))'
        - message: The plugin field is immutable
          rule: self.plugin == oldSelf.plugin
```

例如其中的这句 self.plugin == oldSelf.plugin，self 和 oldSelf 代表了变化前后的资源对象， 一旦定义了 plugin 字段的内容，则不允许修改它。

此外，CEL 还有非常丰富的特性，可以通过在线的 Playground 来体验它 https://playcel.undistro.io/

