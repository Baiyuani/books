
```shell
# create a secret using specified subcommand.

#   docker-registry Create a secret for use with a Docker registry
#   generic         Create a secret from a local file, directory or literal value
#   tls             Create a TLS secret

# Usage:
#   kubectl create secret [flags] [options]


kubectl create secret generic NAME -n NAMESPACE \
--from-literal=
--dry-run=client -o yaml | kubectl apply -f -

```