https://github.com/mikefarah/yq#readme
https://mikefarah.gitbook.io/yq/usage/front-matter



```yaml
---
bob:
  item1:
    cats: bananas
  item2:
    cats: apples
```


```shell
yq eval '.bob.*.cats' sample.yaml
```


```shell
- bananas
- apples
```
