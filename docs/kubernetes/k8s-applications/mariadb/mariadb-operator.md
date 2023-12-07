## mariadb-operator

https://github.com/mariadb-operator/mariadb-operator


```shell
helm repo add mariadb-operator https://mariadb-operator.github.io/mariadb-operator
helm install mariadb-operator mariadb-operator/mariadb-operator


kubectl apply -f examples/manifests/config
kubectl apply -f examples/manifests/mariadb_v1alpha1_mariadb.yaml

kubectl apply -f examples/manifests/mariadb_v1alpha1_database.yaml
kubectl apply -f examples/manifests/mariadb_v1alpha1_user.yaml
kubectl apply -f examples/manifests/mariadb_v1alpha1_grant.yaml

kubectl apply -f examples/manifests/sqljobs
```




