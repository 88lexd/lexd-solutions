# Helm Chart - Prometheus and Grafana
Deploys Prometheus and Grafana into the Kubernetes cluster.

This chart was inspired by:
  - https://devopscube.com/setup-prometheus-monitoring-on-kubernetes/
  - https://devopscube.com/setup-kube-state-metrics/
  - https://devopscube.com/node-exporter-kubernetes/

All is done to wrapped this into a Helm chart and made a few changes to suit my own requirements for deployment.

## ClusterRole
This chart deploys a ClusterRole which can only exist once per cluster.

## How to deploy
Note: The namespace `monitoring` is created by Ansible during setup and is also defined in `values.yaml` in case this needs to be changed.
```shell
$ helm [install/upgrade] prometheus-grafana .
```