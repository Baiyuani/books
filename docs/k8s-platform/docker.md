# Note

## daemon.json

```json
{
    "debug": false,
    "insecure-registries": [
      "0.0.0.0/0"
    ],
    "ip-forward": true,
    "ipv6": false,
    "live-restore": true,
    "log-driver": "json-file",
    "log-level": "warn",
    "log-opts": {
      "max-size": "100m",
      "max-file": "2"
    },
    "selinux-enabled": false,
    "metrics-addr" : "0.0.0.0:9323",
    "experimental" : true,
    "storage-driver": "overlay2"
  }
```
