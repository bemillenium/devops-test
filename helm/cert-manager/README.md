# Cert Manager

- Install Cert Manager

```shell
helm repo add jetstack https://charts.jetstack.io
helm install cert-manager jetstack/cert-manager -n kube-system -f values-oozou.yaml --version v1.5.3
```

- Create cluster issuer and cert
  ```shell
  kubectl apply -f manifests/cloudflare-api-token.yaml
  kubectl apply -f manifests/wildcard-millenium-me.me.yaml
  ```

# Sync secert with Kubed
- Add annotations to sync tls
  `kubed.appscode.com/sync: "true"`
