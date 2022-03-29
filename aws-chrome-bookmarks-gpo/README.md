# Simple Site for Converting YAML to JSON for Chrome Bookmark GPO
When managing Google Chrome Bookmarks via GPO, you must create a JSON formatted document that contains the bookmarks you want. Working with JSON directly especially in a single line, it is almost impossible.

This website will allow the conversion of a YAML file and allow you to convert it into a single line JSON which you can copy and paste it into Windows GPO (Group Policy Object).

## Summary
This web application is written in Python and is powered by Flask. It is running on Kubernetes and is deployed via a Helm chart. VS Code is used for development and debugging.

## Build Container Image
Note: This will be automated using GitHub Actions but documenting the manual process for future reference.
```
$ cd container-image/
$ docker build -t 88lexd/chrome-bookmarks-gpo .
$ docker login
  # Login with creds
$ docker push 88lexd/chrome-bookmarks-gpo
```

## Deploy helm Chart
This chart will use the container image that is pushed to DockerHub from the step above.

**First Deployment**
```
$ cd k8s_helm/
$ helm install chrome-bookmarks-gpo . --namespace=dev --values=values-dev-local.yaml
```

**Future Updates**
```
$ cd k8s_helm/
$ helm upgrade chrome-bookmarks-gpo . --namespace=dev --values=values-dev-local.yaml
```

# Remote Development and Debugging using VS Code and Okteto
Using VS Code to remotely debug code makes everything so much easier. The notes here shows how I have configured Okteto and VS Code to work together when debugging code from within a k8s pod.

## Kubernetes StorageClass
Okteto requires a default storage class available otherwise we can also specify our own storage class in the `okteto.yml` file.

As I am using the `nfs-subdir-external-provisioner` in my cluster, I must specify this in the config.

Example of the storage class:
```
$ kubectl get sc
NAME         PROVISIONER                                     RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
nfs-client   cluster.local/nfs-subdir-external-provisioner   Delete          Immediate           true                   60d
```

Example of how I configure `okteto.yml`
```
---
name: chrome-bookmarks-gpo-deployment
image: 88lexd/chrome-bookmarks-gpo:latest
command: bash
sync:
- ./app:/app
forward:
- 5678:5678
persistentVolume:
  enabled: true
  storageClass: nfs-client  # <=============
  size: 5Gi
```

## Configure VS Code launch.json
The `launch.json` file in VS code should contain the following:
```
{
      "name": "Python: Okteto Attach",
      "type": "python",
      "request": "attach",
      "port": 5678,
      "host": "localhost",
      "pathMappings": [
        {
          "localRoot": "${fileDirname}",  // <=== will expand on this later
          "remoteRoot": "/app"
        }
      ]
    }
```

## Launch Okteto
By running the following command, Okteto will temporarily remove the pod in `chrome-bookmarks-gpo-deployment` and replace it with the development pod.
```
$ cd container-image/
$ okteto up --namespace=dev
 i  Using dev @ kubernetes-admin@kubernetes as context
 ✓  Images successfully pulled
 ✓  Files synchronized
    Context:   kubernetes-admin@kubernetes
    Namespace: dev
    Name:      chrome-bookmarks-gpo-deployment
    Forward:   5678 -> 5678

bash-5.0#
```

Start the application by calling `main.py`. Example:
```
bash-5.0# python3 /app/main.py
 * Serving Flask app 'src' (lazy loading)
 * Environment: production
   WARNING: This is a development server. Do not use it in a production deployment.
   Use a production WSGI server instead.
 * Debug mode: on
 * Running on all addresses.
   WARNING: This is a development server. Do not use it in a production deployment.
 * Running on http://172.16.128.2:80/ (Press CTRL+C to quit)
 * Restarting with stat
 * Debugger is active!
 * Debugger PIN: 123-456-789
```

## Begin Coding and Debugging
The `./container-image/app` directory is sync to `/app` on the remote server. Any changes made locally on VS Code will show up inside the container.

To begin code debug, use `debugpy` and set the breakpoint(). Example:
```
# views.py
from . import app
import debugpy

@app.route("/")
def hello_world():
    a = "alex"
    debugpy.listen(5678)
    print("Waiting for debugger attach")
    debugpy.wait_for_client()
    debugpy.breakpoint()
    return "Hello World from Flask"
```

Access this route and allow the code to hit the break point. Example:
```
$ curl -H "Host: cb-gpo.dev.lexdsolutions.local" http://192.168.0.13
```

Go back to VS Code and select the `Python: Okteto Attach` config for debug and then run debug (F5) on the file `./container-image/app/main.py`

VS Code is now in debug mode and we can step through each code line by line.

## Stopping Okteto
Run the following command to stop development
```
$ okteto down --namespace=dev
 i  Using dev @ kubernetes-admin@kubernetes as context
 ✓  Development container deactivated
```

### Lingering Objects
As Okteto has created a PVC, if we no longer require this then to do a full clean up, do the following:

Delete the volumes created by Okteto
```
$ kubectl get pvc -n dev
NAME                                     STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
chrome-bookmarks-gpo-deployment-okteto   Bound    pvc-77432a6d-66ee-44c4-9165-9c4ae42bd32a   5Gi        RWO            nfs-client     7m57s

$ okteto down --namespace=dev --volumes
i  Using dev @ kubernetes-admin@kubernetes as context
 ✓  Development container deactivated
 ✓  Persistent volume removed

$ kubectl get pvc -n dev
No resources found in dev namespace.
```

Delete the archived sub-dir created by the provisioner. Check the nfs-subdir provisioner pod to see the NFS location.
