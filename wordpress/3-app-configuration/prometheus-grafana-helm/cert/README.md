# TLS Certificate for Prometheus Ingress
A TLS certificate is required by the ingress, otherwise Google Chrome doesn't like it.

Seems like Prometheus does an auto HTTPS redirection even though I didn't configure it to use HTTPS initially..

This is a self signed certificate with a 100 year expiration.

## Important
This TLS certificate only works on Firefox where you can stil continue through the website.

In Google Chrome, because the CN is using `.com`, it completely prevents me from accessing the site.

As I do not run my own customer DNS server locally and I do not want to allow this service to be accessible over the internet, I will be using `NodePort` on the service through Chrome instead.

## How the cert is configured.
- Setup the `request.txt` with the relevant information such as CN and SANS
- Generate private key
  ```
  $ openssl genrsa -out cert.key 2048
  ```
- Create the self signed certificate
  ```
  $ openssl req -x509 -nodes -days 36500 -newkey rsa:2048 -keyout cert.key -out cert.crt -config request.txt -extensions 'v3_req'
  ```
- Validate the cert
  ```
  $ openssl x509 -text -noout -in cert.crt
  Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            7c:c8:02:57:ae:60:24:5d:e4:a1:de:a8:bb:dc:2b:8f:de:2f:89:e0
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: C = AU, ST = NSW, L = Sydney, O = LexdSolutions, OU = IT, CN = prometheus.lexdsolutions.com
        Validity
            Not Before: Mar 19 10:08:54 2024 GMT
            Not After : Feb 24 10:08:54 2124 GMT
        Subject: C = AU, ST = NSW, L = Sydney, O = LexdSolutions, OU = IT, CN = prometheus.lexdsolutions.com
  ...
  ```
- Generate a base64 string for the Helm chart to create the secret for TLS
  ```
  # tls.key
  $ cat cert.key | base64 -w0
  LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tCk1JSUV...

  # tls.crt
  cat cert.crt | base64 -w0
  LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUQ0akNDQXN...
  ```
