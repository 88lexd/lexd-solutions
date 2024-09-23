#!/bin/bash

# Set up Postfix main configuration
cat << EOF > /etc/postfix/main.cf
relayhost = [$UPSTREAM_SMTP]:$UPSTREAM_PORT

inet_protocols = ipv4

smtp_sasl_auth_enable = yes
smtp_sasl_security_options = noanonymous
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
smtp_tls_security_level = may
smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt

# Canonical address mapping to change the 'FROM' address
canonical_maps = regexp:/etc/postfix/canonical

# Allow relaying from the following internal networks
mynetworks = 192.168.0.0/24, 127.0.0.1/32
EOF


# Set up canonical mapping to rewrite FROM address
cat << EOF > /etc/postfix/canonical
/.+/ $FROM_ADDRESS
EOF


# Add authentication credentials for the upstream SMTP server
echo "[$UPSTREAM_SMTP]:$UPSTREAM_PORT $SMTP_USER:$SMTP_PASS" > /etc/postfix/sasl_passwd


# Secure the password file and postmap it
chmod 600 /etc/postfix/sasl_passwd
postmap /etc/postfix/sasl_passwd

# Postmap canonical file
postmap /etc/postfix/canonical

postconf maillog_file=/dev/stdout

# Start Postfix in the foreground
/usr/sbin/postfix start-fg
