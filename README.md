![Oozou](https://cdn.oozou.com/assets/logo-29352bd92fe47c629c5ff5f3885ed9fea425a4cf4db8ccc8ba253ad2fe2d373d.png)


## Introduction

This is a technical test for the role of **DevOps Engineer**.

## Objectives

This test helps us to understand
- how do you approach infrastructure design
- how do you manage microservices communication
- how do you consider security implications

## Project Setup

Project root has [`index.js`](/index.js) file. It simulates a simple app that runs infinitely & sends metrics to a [`statsd`](https://github.com/statsd/statsd) server.

## Exercices

  1. Add a `Dockerfile` to containerize the app, with support for multiple environments (test, development & production)
  2. Add a `docker-compose.yml` file to setup Node app, `statsd` & the backend. Applicants can use any backends for `statsd` (eg: `Graphite`).
  3. Use any IAC tools (Cloudformation, Terraform etc.) to prepare the infrastructure
  4. (Optional) Deploy on any cloud computing platforms

## Submitting Your Code

Email us your Github repo. We expect meaningful git commits, ideally one commit per exercise with commit messages clearly communicating the intent.

In case you deploy it to any cloud platforms, please send us instructions & relevant IAM user credentials.

---
## TLDR;
### Technology and tools
- Docker
- Docker-compose
- Terraform
- OpenVPN
- Kubernetes
- Helm
  - Cert-manager
  - Ingres-nginx
  - Kubed
  - Grafana
  - Graphite

```bash
# Quick Build Docker
$ bash build.sh
```
`Note` Before connect to the cluster. This cluster is the private with no public endpoint except VPN. You need to install the openvpn client first and then import the .ovpn to connect to the cluster.
```bash
# Get cluster credential
$ gcloud auth activate-service-account  developer-service-account-demo@mimetic-surf-230708.iam.gserviceaccount.com --key-file=<keyfile>.json

# Retrive kubeconfig
$ gcloud container clusters get-credentials gke-millenium-oozou --zone asia-southeast1-a --project mimetic-surf-230708

# Get all pods
$ kubectl get pod -A
```
---
# Infrastureture design
![Alt text](img/infra.png?raw=true "XX")
- Seperate project between Non-PRD and PRD
- Create VPCs with a cloud router with auto NAT networking
  - Non-PRD
  - PRD
- In the Non-PRD VPC contains 2 subnets.
  - Develop subnet
    - VM IP-range
    - Pods IP-range
    - Service IP-range
  - Staging subnet
    - VM IP-range
    - Pods IP-range
    - Service IP-range
- In the PRD VPC contains 1 subnet.
  - Production subnet
    - VM IP-range
    - Pods IP-range
    - Service IP-range
- Create a VPN in each subnet for private access.
- The GKE access must be used with IAM policy

`Note` In this submit. The time is not enough to provision all the environments. I have provisioned only the `Non-PRD` VPC with `Develop subnet` that contains `VMs,Pods,Services IP Range`.

`Note About the naming` The naming in this submit is not as same as the diagram because I do it with the limited time and I don't want to rerun my terraform to recreate it again!

# How to access
- Install openvpn client to your computer. (Viscosity is recommended.)
- Import .ovpn file that send it by email.
## View app metric that send by your app to graphite and visulize by Grafana.
![Alt text](img/grafana.png?raw=true "XX")
- Connect the VPN and check by go to `https://monitoring.oozou.millenium-m.me/`, you must see grafana web is shown.
- Login the Grafana with username password that send by email.
- Go to Dashboard `millenium-oozou`, you will see the real time you app stats. enjoy!

## Let's check the infrastructure in k8s
```bash
# Get cluster credential
$ gcloud auth activate-service-account  developer-service-account-demo@mimetic-surf-230708.iam.gserviceaccount.com --key-file=<keyfile>.json #send by email.

# Retrive kubeconfig
$ gcloud container clusters get-credentials gke-millenium-oozou --zone asia-southeast1-a --project mimetic-surf-230708

# Get all pods
$ kubectl get pod -A

echo "you can do anything that you want, but you will be only a Developer as the role that I design."
```
![Alt text](img/all-pods.png?raw=true "XX")