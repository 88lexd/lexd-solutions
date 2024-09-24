# SMTP Relay
With a recent change from my email provider now blocking Basic Authentication, I have now went with a different SMTP service.

To ensure that I can future proof myself, I am setting up this SMTP relay service so all my internal services don't ever need to change again if I do decide to later change providers in the future.

This service will use `nullmailer` and is run as a standalone container under the management machine.

## Build
```shell
# In WSL
$ sudo service docker start

$ docker build -t 88lexd/smtp-relay .

$ docker login
# Login with creds
$ docker push 88lexd/smtp-relay
```

## Run
```shell
docker run -d --name smtp-relay \
  --rm \
  -e DEFAULT_DOMAIN=lexdsolutions.com \
  -e ADMIN_ADDR=noreply@lexdsolutions.com \
  -e SMTP_SERVER=some-smtp-server.com \
  -e SMTP_PORT=587 \
  -e SMTP_USER=myuser \
  -e SMTP_PASS=somepassword123 \
  -p 25:25 \
  88lexd/smtp-relay
```

Clean up if required
```shell
docker stop smtp-relay && docker rm smtp-relay
```

## Test SMTP
```
# If required; install package and select no configuration when prompted
docker exec -it smtp-relay bash

# Inside the container run:
echo "test" |  mail -r "noreply@lexdsolutions.com" -s "This is just a test with nullmailer" "myemail@domain.com"
```
