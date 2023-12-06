

```bash
kubectl autoscale deployment example -n app1 \
--min=2 \
--max=5 \
--cpu-percent=80
```