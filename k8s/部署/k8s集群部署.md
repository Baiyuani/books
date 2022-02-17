# k8s集群部署
latest: 建议在尝试新功能时使用。
stable: 建议在生产环境中使用。（推荐）
alpha: 未来版本的实验性预览。
helm repo add rancher-<CHART_REPO> https://releases.rancher.com/server-charts/<CHART_REPO>

kubectl create namespace cattle-system

openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout kube-rancher.key -out kube-rancher.crt -subj "/CN=kube.rancher.com/O=kube.rancher.com"

kubectl create secret tls rancher-tls --key kube-rancher.key --cert kube-rancher.crt -n cattle-system

helm install rancher rancher-stable/rancher \
 --namespace cattle-system \
 --set hostname=kube.rancher.com \
 --set replicas=1 \
 --set ingress.tls.source=rancher-tls







