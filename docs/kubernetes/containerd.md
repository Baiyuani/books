---
tags:
  - container
---

## crictl load镜像

```shell
# 查看命名空间
ctr ns ls
NAME    LABELS 
default        
k8s.io 

# k8s使用的镜像位于k8s.io中
ctr -n k8s.io images ls

# 载入镜像到k8s.io命名空间
ctr -n k8s.io images import openjdk.tar.gz 

# 查看刚载入的镜像
crictl images
```
