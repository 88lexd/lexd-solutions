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

    # debugpy.listen(5678)
    # print("Waiting for debugger attach")
    # debugpy.wait_for_client()
    # debugpy.breakpoint()

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

    # Get data from secrets and configmap and save as temp files
    _prep_files(corev1api, k8s_namespace)

    # Use openssl binary to generate CSR
    subprocess.Popen(_cmd("openssl req -new -sha256 -nodes -out cert.csr -key private.key -config details.txt")).communicate()

    # This dir is an underlying NFS mount (PV). It is the same as the WordPress pods. Any files here will be public
    challenge_dir = '/var/www/html/.well-known/acme-challenge'
    os.makedirs(challenge_dir, exist_ok=True)
    sub_state_stdout, sub_state_stderr = subprocess.Popen(_cmd(f"python3 acme_tiny.py --account-key account.key --csr cert.csr --acme-dir {challenge_dir}"),
        stdout=subprocess.PIPE, stderr=subprocess.PIPE).communicate()

    debugpy.listen(5678)
    print("Waiting for debugger attach")
    debugpy.wait_for_client()
    debugpy.breakpoint()
    #  > lexdsolutions.com.crt

    # Cleanup files for security purposes
    files_to_clean = ('account.key', 'private.key', 'details.txt', 'cert.csr')
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


# Helper function for popen. Makes it easier to read the code
def _cmd(_):
    return _.split()


if __name__ == "__main__":
    main()
