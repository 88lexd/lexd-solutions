# SMTP Relay
With a recent change from my email provider now blocking Basic Authentication, I have now went with a different SMTP service.

To ensure that I can future proof myself, I am setting up this SMTP relay service so all my internal services don't ever need to change again if I do decide to later change providers in the future.

This service will use `nullmailer` and is run as a standalone container under the management machine.

## Build
```shell
# In WSL
sudo service docker start

docker build -t 88lexd/smtp-relay .

docker login
# Login with creds

docker push 88lexd/smtp-relay
```

## Run
```shell
docker run -d --restart unless-stopped --name smtp-relay \
  -e SMTP_SERVER=smtp-server.com \
  -e SMTP_PORT=587 \
  -e SMTP_USER=123@server.com \
  -e SMTP_PASS=super-password \
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
echo "$(whoami)@$(hostname)" | mail --subject=testsubject --append="From: noreply@lexdsolutions.com" test@domain.com
```
