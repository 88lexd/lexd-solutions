# LetEncrypt Cron - Docker Image
Note: There are many exsting tools out there to help auto renew certificates... but doing one myself will allow me to learn every aspect to it.

This Docker image is designed to help auto renew the TLS certificate used on https://lexdsolutions.com.

It will closely follows what I have done manually by storing the challenge files into the NFS directory.

See: https://github.com/88lexd/lexd-solutions/tree/main/aws-wordpress/3-app-configuration/lets-encrypt

## Build Image
```
$ docker build -t 88lexd/lets-encrypt-cron .
```

## Run Interactively to Test
Will mount source code to /app_local
```
$ docker run --rm -it -v $(pwd)/src:/app_local --entrypoint /bin/bash --workdir /app_local 88lexd/lets-encrypt-cron

TOKEN='eyJhbGciOiJSUzI...'
$ python3 main.py --token $TOKEN
```

## Push Image to Docker Hub
Git Hub Actions is being used to perform CI over to Docker Hub. See the workflow:

https://github.com/88lexd/lexd-solutions/blob/main/.github/workflows/lets-encrypt-cron-img.yml

A simply push/merge request to the main branch is enough to trigger the workflow.

Once the action completes, the new image will be available at: https://hub.docker.com/r/88lexd/lets-encrypt-cron

## Manual Push to Docker Hub
For whatever reason to push this image up to Docker Hub manuall, then use the following command:
```
$ docker login
# Login with creds
$ docker push 88lexd/lets-encrypt-cron
```
