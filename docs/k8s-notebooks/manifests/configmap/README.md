```shell
# 由configmap导出yaml的方法：
kubectl get configmap [configmap名] -o yaml
# 使用目录创建（--fromfile 指定在目录下的所有文件都会被用在ConfigMap里面创建一个键值对，键的名字就是文件名，值就是文件的内容）
kubectl create configmap [configmap名称] --from-file=[目录]
# 使用文件创建（--fromfile 这个参数可以使用多次，你可以使用两次分别指定上个实例中的那两个配置文件，效果就跟指定整个目录是一样的）
kubectl create configmap [configmap名称] --from-file=[文件]
# 从字面值创建
kubectl create configmap [configmap名称] --from-literal=[键值对]
```
