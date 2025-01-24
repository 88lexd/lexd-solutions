# Helm Chart - Prometheus and Grafana
Deploys Prometheus, Grafana and Loki into the Kubernetes cluster.

This chart was inspired by:
  - https://devopscube.com/setup-prometheus-monitoring-on-kubernetes/
  - https://devopscube.com/setup-kube-state-metrics/
  - https://devopscube.com/node-exporter-kubernetes/

All is done to wrapped this into a Helm chart and made a few changes to suit my own requirements for deployment.

The Loki portion of the configuration is all custom for my specific chart.

## ClusterRole
This chart deploys a ClusterRole which can only exist once per cluster.

## How to deploy
### Grafana Loki and Promtail
Loki and Promtail provides logging capability.
```shell
$ helm repo add grafana https://grafana.github.io/helm-charts
$ helm repo update

# Install Loki
# Get version: `$ helm search repo loki`
$ helm upgrade loki --install -n grafana-loki --values values-grafana-loki.yaml grafana/loki --version "5.47.1" --create-namespace

# Install Promtail
# Get version: `$ helm search repo promtail`
$ helm upgrade promtail --install --values values-promtail.yaml grafana/promtail --version "6.15.5" -n grafana-loki

# Get secret off
```

### Prometheus and Grafana
Prometheus and Grafana provides monitoring capability.

Note: The namespace `monitoring` is created by Ansible during setup and is also defined in `values.yaml` in case this needs to be changed.
```shell
$ helm upgrade --install prometheus-grafana .
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

## Troubleshooting
### Promtail
Promtail ships logs to Loki, but when I first deployed this, it wasnt sending log for some of my pods. The following is used for troubleshooting.

Create a port forward so I can access the service cluster IP of the promtail service.

```shell
# Get the promtail pod name (running as daemon set, check master and worker node as required)
# Port is <local-port>:<promtail-port>
$ kubectl port-forward -n grafana-loki pod/promtail-xxx 3101:3101
```

Open a browser and connect to: http://127.0.0.1:3101/targets

This will show the targets which promtail is currently fetching logs from.
