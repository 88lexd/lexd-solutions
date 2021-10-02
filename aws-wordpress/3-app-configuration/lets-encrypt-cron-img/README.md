# LetEncrypt Cron - Docker Image
Note: There are many exsting tools out there to help auto renew certificates... but doing one myself allows me to learn every aspect to it.

This Docker image is designed to help auto renew the Let's Encrypt TLS certificate used on https://lexdsolutions.com. It closely follows what I have done manually by storing the challenge files into the NFS directory.

See: https://github.com/88lexd/lexd-solutions/tree/main/aws-wordpress/3-app-configuration/lets-encrypt

## Build Image
```
$ docker build -t 88lexd/lets-encrypt-cron .
```

## Run Interactively to Test
Use command while developing using local MicroK8s cluster (local VM). This will mount source code to /app_local
Note: Token is taken from the pod which uses the service account that has the role allowed to use API.

On the pod, extract the tokenfrom: `/var/run/secrets/kubernetes.io/serviceaccount/token`
```
$ docker run --rm -it -v $(pwd)/src:/app_local --entrypoint /bin/bash --workdir /app_local 88lexd/lets-encrypt-cron

TOKEN='eyJhbGciOiJSUzI...'
HOST='https://192.168.198.101:16443'
$ python3 main.py --token $TOKEN --host=$HOST
```

## Push Image to Docker Hub
Git Hub Actions is being used to perform CI over to Docker Hub. See the workflow:

https://github.com/88lexd/lexd-solutions/blob/main/.github/workflows/lets-encrypt-cron-img.yml

A simple push/merge request to the main branch is enough to trigger the workflow.

Once the action completes, the new image will be available at: https://hub.docker.com/r/88lexd/lets-encrypt-cron

## Manual Push to Docker Hub
For whatever reason I need to manually push this image up to Docker Hub, then use the following command:
```
$ docker login
# Login with creds
$ docker push 88lexd/lets-encrypt-cron
```
