# SMTP Relay
With a recent change from my email provider now blocking Basic Authentication, I have now went with a different SMTP service.

To ensure that I can future proof myself, I am setting up this SMTP relay service so all my internal services don't ever need to change again if I do decide to later change providers in the future.

This service will use Postfix and is run as a standalone container under the management machine.

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
  -e UPSTREAM_SMTP=smtp-relay.brevo.com \
  -e UPSTREAM_PORT=587 \
  -e SMTP_USER=xxxxxx@smtp-brevo.com \
  -e SMTP_PASS=xxxx \
  -e FROM_ADDRESS=notifications@lexdsolutions.com \
  -p 25:25 \
  88lexd/smtp-relay
```

Clean up if required
```shell
docker stop smtp-relay && docker rm smtp-relay
```

## Test SMTP (NOT WORKING???)
```
# If required; install package and select no configuration when prompted
sudo apt-get install -y mailutils

echo "Test email - $(date)" | mail -s "Test Subject" -S smtp=smtp://192.168.0.21:25 alex.dinh@hotmail.com
```
