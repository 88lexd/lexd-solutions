#!/bin/bash

mkdir -p /etc/smtpd/tables

# Secrets
cat << EOF > /etc/smtpd/tables/relay_secrets
# Syntax: alias smtp-username:smtp-password

# SMTP account for Brevo
myalias ${SMTP_USER}:${SMTP_PASS}
EOF


# Permissions
chmod -R 750 /etc/smtpd/
chmod 640 /etc/smtpd/tables/relay_secrets
chown -R root:opensmtpd /etc/smtpd/


# Main Config
cat << EOF > /etc/smtpd.conf
table relay_secrets file:/etc/smtpd/tables/relay_secrets

listen on 0.0.0.0 port 25

listen on socket

action "my_relay" relay host smtp+tls://myalias@${SMTP_SERVER}:${SMTP_PORT} auth <relay_secrets>

match from any for any action "my_relay"
EOF

# Start daemon in debug (use -dv with debug!)
smtpd -d