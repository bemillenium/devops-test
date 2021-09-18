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


## TLDR
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