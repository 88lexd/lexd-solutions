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
