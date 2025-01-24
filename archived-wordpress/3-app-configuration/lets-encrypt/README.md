# Lets Encrypt SSL/TLS Certificate
Currently I am running this manually to get the certificate and then load it into K8s secres for Ingress to consume.

Eventually this needs to be automated as the certificate only lasts 90 days!

This is powered by a Python script which is from: https://github.com/diafygi/acme-tiny

## How to Request for a Certificate
 - First create an `account key`. (this is not used for signing the CSR!)
    ```
    $ openssl genrsa 4096 > account.key
    ```

 - Create another `private key` to sign the CSR
    ```
    $ openssl genrsa 4096 > lexdsolutions.com.key
    ```

 - Create a CSR by using the details.txt file. This will create a CSR file called `lexdsolutions.com.csr`
    ```
    $ openssl req -new -sha256 -nodes -out lexdsolutions.com.csr -key lexdsolutions.com.key -config lexdsolutions.com_details.txt
    ```

 - Setup the webserver and have it ready for the ACME challenge.
    ```
    # Note: /nfs/k8s/ is a persistent storage my WordPress, so I can create the file directly here for the web service to consume.

    $ sudo mkdir -p /nfs/k8s/prod-wordpress-pvc-pvc-3761c4b3-dbef-4cc3-a6cc-30702c0c5859/.well-known/acme-challenge;

    $ python3 acme_tiny.py --account-key account.key --csr my.csr --acme-dir /nfs/k8s/prod-wordpress-pvc-pvc-3761c4b3-dbef-4cc3-a6cc-30702c0c5859/.well-known/acme-challenge > lexdsolutions.com.crt
    ```

  - Save keypair as K8s secret for Ingress to consume
    ```
    $ kubectl -n prod create secret tls lexdsolutions.com.tls --cert=lexdsolutions.com.crt --key=lexdsolutions.com.key
    secret/lexdsolutions.com.tls created
    ```
