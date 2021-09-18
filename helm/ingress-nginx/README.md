```console
## Add the Ingress Nginx Helm repository
$ helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

## Install the cert-manager helm chart
$ helm install ingress-nginx ingress-nginx/ingress-nginx -n kube-system -f values-millenium-oozou.yaml --version 4.0.1
```
