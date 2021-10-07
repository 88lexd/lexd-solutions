from kubernetes import client, config
import kubernetes.client
import argparse
import base64
import os
import subprocess
import debugpy


def main():
    parser = _get_parser()
    global opts
    opts = parser.parse_args()

    if opts.cluster_config:
        config.load_incluster_config()
        corev1api = client.CoreV1Api()
        with open('/var/run/secrets/kubernetes.io/serviceaccount/namespace', 'r') as f:
            k8s_namespace = f.read()
    else:
        if opts.host is None or opts.namespace is None:
          print("Missing --host or --namespace input!")
          exit(1)

        k8s_namespace = opts.namespace
        configuration = kubernetes.client.Configuration()
        configuration.api_key['authorization'] = opts.token
        configuration.api_key_prefix['authorization'] = 'Bearer'
        configuration.host = opts.host
        configuration.verify_ssl=False

        # Enter a context with an instance of the API kubernetes.client
        with kubernetes.client.ApiClient(configuration) as api_client:
            corev1api = kubernetes.client.CoreV1Api(api_client)

    if not os.environ.get('LE_ACCOUNT_KEY_NAME'):
        print('Missing LE_ACCOUNT_KEY in environmental variables!')
        exit(1)
    if not os.environ.get('LE_PRIVATE_KEY_NAME'):
        print('Missing LE_PRIVATE_KEY_NAME in environmental variables!')
        exit(1)
    if not os.environ.get('LE_CSR_CONFIGMAP_NAME'):
        print('Missing LE_CSR_CONFIGMAP_NAME in environmental variables!')
        exit(1)
    if not os.environ.get('LE_TLS_SECRET_NAME'):
        print('Missing LE_TLS_SECRET_NAME in environmental variables!')
        exit(1)

    # TO DO
    """
    - Check SSL certificate for expiry. Should only renew/create if
        1) cert is about to expire (<30 days)
        2) is using the default Kubernetes certificate
    - Configure k8s cronjob for this
    """

    # Get data from secrets and configmap and save as temp files
    _prep_files(corev1api, k8s_namespace)

    print ("Begin requesting certficate from Lets Encrypt... ")
    # Use openssl binary to generate CSR
    subprocess.Popen(_cmd("openssl req -new -sha256 -nodes -out cert.csr -key private.key -config details.txt")).communicate()

    # This dir is an underlying NFS mount (PV). It is the same as the WordPress pods. Any files here will be public
    challenge_dir = '/var/www/html/.well-known/acme-challenge'
    os.makedirs(challenge_dir, exist_ok=True)

    if (opts.staging):
        directory_url = "--directory-url https://acme-staging-v02.api.letsencrypt.org/directory"
    else:
        directory_url = ""
    sub_state_stdout, sub_state_stderr = subprocess.Popen(_cmd(f"python3 acme_tiny.py --account-key account.key --csr cert.csr --acme-dir {challenge_dir} {directory_url}"),
        stdout=subprocess.PIPE, stderr=subprocess.PIPE).communicate()

    print("Saving signed certificate file!")
    with open('signed.cer', 'w') as _file:
        _file.writelines(sub_state_stdout.decode('utf-8'))

    _update_tls_secret(corev1api, k8s_namespace)

    # Cleanup files for security purposes
    files_to_clean = ('account.key', 'private.key', 'details.txt', 'cert.csr', 'signed.cer')
    print("Cleaning temp files...")
    for _file in files_to_clean:
        print(f" - Removing {_file}")
        os.remove(_file)

    print("Script completed!")


def _get_parser():
    parser = argparse.ArgumentParser()
    actions_group = parser.add_mutually_exclusive_group(required=True)
    actions_group.add_argument("--cluster-config", action="store_true" , help="Use cluser config. Only applicable when using inside a pod!")
    actions_group.add_argument("--token" , help="Apply a valid API token")

    parser.add_argument("--host", help="The K8s host! including the port. e.g. 192.168.x.x:16443")
    parser.add_argument("-n","--namespace", help="Name of the Kubernetes namespace")
    parser.add_argument("--staging", action="store_true" , help="Use Lets Encrypts staging servers instead of prod! (recommended for dev)")
    return parser


def _prep_files(corev1api, k8s_namespace):
    print(f"Getting secret data from [{os.environ['LE_ACCOUNT_KEY_NAME']}] in namespace [{k8s_namespace}]")
    account_key_base64 = corev1api.read_namespaced_secret(os.environ['LE_ACCOUNT_KEY_NAME'], k8s_namespace).data.get('key')
    account_key_string = base64.b64decode(account_key_base64).decode('utf-8')
    with open("account.key", "w") as out_file:
        out_file.writelines(account_key_string)

    print(f"Getting secret data from [{os.environ['LE_PRIVATE_KEY_NAME']}] in namespace [{k8s_namespace}]")
    private_key_base64 = corev1api.read_namespaced_secret(os.environ['LE_PRIVATE_KEY_NAME'], k8s_namespace).data.get('key')
    private_key_string = base64.b64decode(private_key_base64).decode('utf-8')
    with open("private.key", "w") as out_file:
        out_file.writelines(private_key_string)

    print(f"Getting configmap data from [{os.environ['LE_CSR_CONFIGMAP_NAME']}]] in namespace [{k8s_namespace}]")
    csr_config = corev1api.read_namespaced_config_map(os.environ['LE_CSR_CONFIGMAP_NAME'], k8s_namespace).data.get('csr_details')
    with open("details.txt", "w") as out_file:
        out_file.writelines(csr_config)


def _update_tls_secret(corev1api, k8s_namespace):
    with open('signed.cer', 'r') as _file:
        signed_cert = _file.read()

    private_key_base64 = corev1api.read_namespaced_secret(os.environ['LE_PRIVATE_KEY_NAME'], k8s_namespace).data.get('key')
    b64_cert = base64.b64encode(bytes(signed_cert, "utf-8")).decode('utf-8')

    secrets = corev1api.list_namespaced_secret(k8s_namespace)
    secret_names = [item._metadata.name for item in secrets._items]

    tls_secret_name = os.environ['LE_TLS_SECRET_NAME']

    if tls_secret_name in secret_names:
        print(f"Found existing TLS secret called [{tls_secret_name}]. Deleting it to create new one...")
        corev1api.delete_namespaced_secret(tls_secret_name, k8s_namespace)

    print(f"Creating new TLS secret called [{tls_secret_name}]")
    secret = client.V1Secret()
    secret.metadata = client.V1ObjectMeta(name=tls_secret_name)
    secret.type = 'tls'
    secret.data = {'tls.crt': b64_cert, 'tls.key': private_key_base64}
    corev1api.create_namespaced_secret(k8s_namespace, body=secret)

# Helper function for popen. Makes it easier to read the code
def _cmd(_):
    return _.split()


if __name__ == "__main__":
    main()
