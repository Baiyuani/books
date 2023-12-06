## Install cert-manager

Note: cert-manager is only required for certificates issued by Rancher’s generated CA (ingress.tls.source=rancher) and Let’s Encrypt issued certificates (ingress.tls.source=letsEncrypt). You should skip this step if you are using your own certificate files (option ingress.tls.source=secret) or if you use TLS termination on an External Load Balancer.


Install the CustomResourceDefinition resources separately
```shell
kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.9/deploy/manifests/00-crds.yaml

```
Create the namespace for cert-manager
```shell
kubectl create namespace cert-manager
```
Label the cert-manager namespace to disable resource validation
```shell
kubectl label namespace cert-manager certmanager.k8s.io/disable-validation=true
```
Add the Jetstack Helm repository
```shell
helm repo add jetstack https://charts.jetstack.io
```
Update your local Helm chart repository cache
```shell
helm repo update
```
Install the cert-manager Helm chart
```shell
helm install cert-manager \
  --namespace cert-manager \
  --version v0.14.2 \
  jetstack/cert-manager
```

Upgrade the cert-manager
```shell
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.5.1/cert-manager.crds.yaml

helm upgrade \
  --install \
  --create-namespace \
  --namespace cert-manager \
  --version v1.5.1 \
  cert-manager \
  jetstack/cert-manager \
   --set ingressShim.defaultIssuerName=letsencrypt-prod \
   --set ingressShim.defaultIssuerKind=ClusterIssuer \
   --set ingressShim.defaultIssuerGroup=cert-manager.io


cat << EOF| kubectl create  -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: ymzhang@quantangle.com.cn
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
       ingress:
         class: nginx
EOF
```

Creating the `rancher` issuer
```shell
cat << EOF| kubectl create -n cattle-system -f -
   apiVersion: cert-manager.io/v1
   kind: Issuer
   metadata:
     name: rancher
   spec:
     acme:
       # The ACME server URL
       server: https://acme-v02.api.letsencrypt.org/directory
       # Email address used for ACME registration
       email: ymzhang@quantangle.com.cn
       # Name of a secret used to store the ACME account private key
       privateKeySecretRef:
         name: rancher
       # Enable the HTTP-01 challenge provider
       solvers:
       - http01:
           ingress:
             class: nginx
EOF

```

3, Rancher Generated Certificates

    Note:
    You need to have cert-manager installed before proceeding.

The default is for Rancher to generate a CA and uses cert-manager to issue the certificate for access to the Rancher server interface. Because rancher is the default option for ingress.tls.source, we are not specifying ingress.tls.source when running the helm install command.

    Set the hostname to the DNS name you pointed at your load balancer.
    If you are installing an alpha version, Helm requires adding the --devel option to the command.

```shell script
kubectl -n kube-system edit cm coredns

```
添加
```shell script
        ready
        hosts {
            10.0.2.17  rancher.qtgl.com.cn
            fallthrough
        }

```
 
本机电脑添加hosts:
```html
121.5.129.198  rancher.qtgl.com.cn
```


```shell

helm install rancher rancher-stable/rancher   \
  --namespace cattle-system \
  --set hostname=rancher.qtgl.com.cn 


```


To get just the bootstrap password on its own, run:

```shell
kubectl get secret --namespace cattle-system bootstrap-secret -o go-template='{{.data.bootstrapPassword|base64decode}}{{ "\n" }}'
```

