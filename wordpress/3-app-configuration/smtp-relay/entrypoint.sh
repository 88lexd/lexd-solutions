#!/bin/bash

echo "$DEFAULT_DOMAIN" > /etc/nullmailer/defaultdomain

echo "$ADMIN_ADDR" > /etc/nullmailer/adminaddr

echo "$SMTP_SERVER smtp --auth-login --port=$SMTP_PORT --starttls --user=$SMTP_USER --pass=\"$SMTP_PASS\"" > /etc/nullmailer/remotes

chmod 600 /etc/nullmailer/remotes

# Fake syslog
touch /var/log/custom_syslog.log && chmod 666 /var/log/custom_syslog.log
socat UNIX-LISTEN:/dev/log,reuseaddr,mode=666,fork SYSTEM:'tee -a /var/log/custom_syslog.log' &

service nullmailer start

tail -f /var/log/custom_syslog.log
