

```shell
kubectl create secret generic ssh-tunnel-pk -n ketanyun --from-file=id_rsa
kubectl -n ketanyun apply -f ssh-tunnel.yaml
```