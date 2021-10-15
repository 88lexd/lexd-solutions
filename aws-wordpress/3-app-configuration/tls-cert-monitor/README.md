# TLS Cert Monitor
This is designed to run as cronjob in Kubernetes and is deployed as a Helm chart.

The script will look at all the ingress controllers in it's own namespace, get the "host" names configured under the "rules" section and will then check the TLS/SSL certificate against those names.

If a certificate is coming to expire, an email will be sent out.
