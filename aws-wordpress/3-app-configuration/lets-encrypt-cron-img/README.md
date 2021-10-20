# Let's Encrypt Cron - Docker Image
Note: There are many exsting tools out there to help auto renew certificates... but doing one myself allows me to learn every aspect to it.

This Docker image is designed to help auto renew the Let's Encrypt TLS certificate used on https://lexdsolutions.com. It closely follows what I have done manually by storing the challenge files into the NFS directory.

See: https://github.com/88lexd/lexd-solutions/tree/main/aws-wordpress/3-app-configuration/lets-encrypt

## Build Image
```
$ docker build -t 88lexd/lets-encrypt-cron .
```

## Push Image to Docker Hub
Git Hub Actions is being used to perform CI over to Docker Hub. See the workflow:

https://github.com/88lexd/lexd-solutions/blob/main/.github/workflows/lets-encrypt-cron-img.yml

A simple push/merge request to the main branch is enough to trigger the workflow.

Once the GitHub Action completes, the new image will be available on [Docker Hub](https://hub.docker.com/r/88lexd/lets-encrypt-cron)

## Manual Push to Docker Hub
For whatever reason I need to manually push this image up to Docker Hub, then use the following command:
```
$ docker login
# Login with creds
$ docker push 88lexd/lets-encrypt-cron
```

## Remote Develop and Debug using VS Code with Okteto
Okteto allows remote development directly inside the pod! This makes it so much easier to write code and debug. It will sync the `./src` directory with `/app` in the container.

Note: Where VS Code is running, kubeconfig must be working and pointing to a K8s cluster (e.g. in my case: I have Windows running VS Code which is using "WSL Target" and WSL has kubeconfig setup to point to a remote K8s cluster).

Download and Install Okteto (this installs to /usr/local/bin/okteto)
```
$ curl https://get.okteto.com -sSfL | sh
```

Take note of the context name. In my case, it is "microk8s". Will need it later.
```
$ cat ~/.kube/config | grep -A3 '\- context\:'
- context:
    cluster: microk8s-cluster
    user: admin
  name: microk8s
```

Deploy Helm Chart (we need the kind: Deployment) for later use.
The Helm Chart includes the template [deployment-lets-encrypt.yaml](https://github.com/88lexd/lexd-solutions/blob/main/aws-wordpress/3-app-configuration/wordpress-helm/templates/deployment-lets-encrypt.yaml).

Note: Must first set the deployment replica to 1!
```
$ cd ../wordpress-helm
$ helm upgrade wordpress-dev . --namespace=dev --values=values-dev.yaml
```

For the first time only. Run `okteto init --namespace=dev` which creates the okteto manifest (okteto.yml). This file is committed to git but putting it here for future reference.

Start okteto! (Note: Foward 5678:5678 means that our local host is now forwarding to the containers 5678 port)
```
$ okteto up --context=microk8s --namespace=dev
 ✓  Images successfully pulled
 ✓  Files synchronized
    Context:   microk8s
    Namespace: dev
    Name:      okteto-lets-encrypt-cron
    Forward:   5678 -> 5678
```

Once Okteto starts, it will start a Bash shell. Now trigger the script manually and it will be ready for VS Code to attach to it. Example:
```
root@okteto-lets-encrypt-cron-6dc99c868d-jpv55:/app# python3 main.py
usage: main.py [-h] (--cluster-config | --token TOKEN) [--host HOST]
main.py: error: one of the arguments --cluster-config --token is required
root@okteto-lets-encrypt-cron-6dc99c868d-jpv55:/app# python3 main.py --cluster-config
Waiting for debugger attach
```

Setup VS Code with the following launch configuration (launch.json). Thanks to the forwarding above, I can now use "localhost" and just need to target port 5678.
```
{
  "name": "Python: Attach",
  "type": "python",
  "request": "attach",
  "port": 5678,
  "host": "localhost",
  "pathMappings": [
    {
      "localRoot": "${fileDirname}",  // This requires me to start debug in ./src/main.py
      "remoteRoot": "/app"
    }
  ]
}
```

To allow VS Code to start debugging, the following snippet must exist in the source code

Note: On VS Code, Start Debugging (F5) on `main.py` in ./src
```
# Example code only, but you get the point that we need to use 'debugpy'
import debugpy

a = 1
b = 2
c = a + b

debugpy.listen(5678)
print("Waiting for debugger attach")
debugpy.wait_for_client()
debugpy.breakpoint()
print(c)
```

**Final Note**: Every time I edit the code in `./src`, it will instantly get sync over to the container! This is all thanks to the okteto manifest (okteto.yml) file!

## Okteto Troubleshooting
When I need to make a change to my Kubernetes deployment, I must first stop Okteto and then apply the changes. Otherwise it will not work properly.

Example (not working):
```
$ okteto up --context=microk8s --namespace=dev
 x   'lets-encrypt-cron' has been modified while your development container was active
    Follow these steps:
          1. Execute 'okteto down'
          2. Apply your manifest changes again: 'kubectl apply'
          3. Execute 'okteto up' again
    More information is available here: https://okteto.com/docs/reference/known-issues/#kubectl-apply-changes-are-undone-by-okteto-up
```

The fix:
```
$ okteto down --context=microk8s --namespace=dev
 ✓  Development container deactivated

$ cd /home/alex/code/git/lexd-solutions/aws-wordpress/3-app-configuration/wordpress-helm
$ helm upgrade wordpress-dev . --namespace=dev --values=values-dev-local.yaml
Release "wordpress-dev" has been upgraded. Happy Helming!
NAME: wordpress-dev
LAST DEPLOYED: Wed Oct  6 11:47:15 2021
NAMESPACE: dev
STATUS: deployed
REVISION: 13
TEST SUITE: None

$ okteto up --context=microk8s --namespace=dev
 ✓  Images successfully pulled
 ✓  Files synchronized
    Context:   microk8s
    Namespace: dev
    Name:      lets-encrypt-cron
    Forward:   5678 -> 5678

root@lets-encrypt-cron-7f74fbc497-6ntmv:/app#
```
