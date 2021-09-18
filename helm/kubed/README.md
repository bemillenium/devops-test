# Add the appscode Helm repository
```bash
$ helm repo add appscode https://charts.appscode.com/stable/
$ helm repo update
```

# Install the kubed helm chart
```bash
$ helm install kubed appscode/kubed -n kube-system --version v0.12.0
```

# Sync object you want with this annotation
```bash
$ kubed.appscode.com/sync: "true"
```
