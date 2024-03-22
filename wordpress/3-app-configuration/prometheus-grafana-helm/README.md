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

## Grafana Configuration
### Data Sources
The Grafana deployment uses a `ConfigMap` for the `prometheus.yaml` which is mounted to `/etc/grafana/provisioning/datasources`.

### SMTP
To get SMTP for alerting, the configuration must be set in the `/etc/grafana/grafana.ini`. As we I didn't want to manually copy the content of this file and put it into a ConfigMap because the file contains 1500 lines. Also if newer versions are released, this file may change and it could potentially break things.

To work with custom configuration, we can environment variables. See: https://grafana.com/docs/grafana/latest/setup-grafana/configure-grafana/

In the `./templates/grafana-deployment.yaml`, I am configuring the SMTP settings and the credentials are taken from Kubernetes as secrets.

The secrets are manually created on the cluster for security reasons. The following is executed to create the secrets:
```
$ kubectl create secret -n monitoring generic grafana-config-smtp --type string --from-literal=username=some-email@sample.com --from-literal=password=abc123
```