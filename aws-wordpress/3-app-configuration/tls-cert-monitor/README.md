# TLS Cert Monitor
This is designed to run as cronjob in Kubernetes and is deployed as a Helm chart.

The script will look at all the ingress controllers in it's own namespace, get the "host" names configured under the "rules" section and will then check the TLS/SSL certificate against those names.

If a certificate is coming to expire, an email will be sent out.

## How to Deploy
Prod
```
$ cd tls-cert-monitor-chart/
$ helm install tls-cert-monitor . -n prod
```

Dev
```
$ cd tls-cert-monitor-chart/
$ helm install tls-cert-monitor . -n dev
```

## Auto Push Image to Docker Hub
Git Hub Actions is being used to perform CI over to Docker Hub. See the workflow:

https://github.com/88lexd/lexd-solutions/blob/main/.github/workflows/tls-cert-monitor.yml

A simple push/merge request to the main branch is enough to trigger the workflow.

Once the action completes, the new image will be available at: https://hub.docker.com/repository/docker/88lexd/tls-cert-monitor

## Manual Push to Docker Hub
Build docker image locally
```
$ docker build -t 88lexd/tls-cert-monitor .
```

Push image to Docker Hub
```
$ docker login
# Login with creds

$ docker push 88lexd/tls-cert-monitor
```

# Remote Development and Debugging using VS Code with Okteto
I've already documented this in the past. Reference [here](https://github.com/88lexd/lexd-solutions/tree/CertMonitorViaIngress/aws-wordpress/3-app-configuration/lets-encrypt-cron-img#remote-develop-and-debug-using-vs-code-with-okteto) for details. This section will be very high level on what to do only.

Download and Install Okteto (this installs to /usr/local/bin/okteto)

```
$ curl https://get.okteto.com -sSfL | sh
```

Update the `dev-deployment.yaml` with 1 replica and deploy the helm chart. Example:

```
$ cd tls-cert-monitor-chart

# This will set the replica to 1, regardless to what the previous number was (once done, set it back to 0!)
$ sed -i 's/replicas:\s\+[0-9]\+/replicas: 1/g' templates/dev-deployment.yaml

$ helm install tls-cert-monitor . -n dev
# OR
$ helm upgrade tls-cert-monitor . -n dev
```

Note: First time only!!! Run okteto init to create the manifest initial file. This creates the `okteto.yml` file
```
$ okteto init --namespace=dev
This command walks you through creating an okteto manifest.
It only covers the most common items, and tries to guess sensible defaults.
See https://okteto.com/docs/reference/manifest/ for the official documentation about the okteto manifest.
Use the arrow keys to navigate: ↓ ↑ → ←
Select the resource you want to develop:
  ▸ dev-tls-cert-monitor-deployment
    Use default values
```

Start Okteto
```
$ okteto up --context=microk8s --namespace=dev
 ✓  Images successfully pulled
 ✓  Files synchronized
    Context:   microk8s
    Namespace: dev
    Name:      dev-tls-cert-monitor-deployment
    Forward:   5678 -> 5678
```

Start developing! Files in ./src is sync over to /app

The terminal will be loaded into a "bash shell" so run `python3 main.py` to manually trigger the script for testing.
