from kubernetes import client, config
import kubernetes.client
import argparse
import base64
import os


def main():
    parser = get_parser()
    global opts
    opts = parser.parse_args()

    script_dir = os.path.dirname(os.path.abspath(__file__))

    if opts.cluster_config:
        config.load_incluster_config()
        v1api = client.CoreV1Api()
    else:
        if opts.host is None:
          print("Missing --host input!")
          exit(1)
        configuration = kubernetes.client.Configuration()
        configuration.api_key['authorization'] = opts.token
        configuration.api_key_prefix['authorization'] = 'Bearer'
        configuration.host = opts.host
        configuration.verify_ssl=False

        # Enter a context with an instance of the API kubernetes.client
        with kubernetes.client.ApiClient(configuration) as api_client:
            v1api = kubernetes.client.CoreV1Api(api_client)

    account_key_base64 = v1api.read_namespaced_secret("lets-encrypt-account-key", "dev").data.get('key')
    account_key_string = base64.b64decode(account_key_base64).decode('utf-8')
    with open(f"{script_dir}/account.key", "w") as out_file:
        out_file.writelines(account_key_string)

    private_key_base64 = v1api.read_namespaced_secret("lets-encrypt-private-key", "dev").data.get('key')
    private_key_string = base64.b64decode(private_key_base64).decode('utf-8')
    with open(f"{script_dir}/private.key", "w") as out_file:
        out_file.writelines(private_key_string)

    """
    TO DO
    1. Working as is. Can read secrets using API through RBAC and secrets are created by using Ansible.
    2. The secret obtained from API can be saved locally and later be used by openssl to create the CSR
          - Challenge here is how I want to pass the details.txt over!? should I use configMap?
    3. Last challenge is the namespace...
          - In the perfect world I can read /run/secrets/kubernetes.io/serviceaccount/namespace
            However, when developing this locally and using K8s API remotely, I cannot get that info as I do from within a pod...
            Realy need to look into a way for remote development from within a pod...

            May need to result to using (and for remote run, then must pass in host + namespace):
            with open("/var/run/secrets/kubernetes.io/serviceaccount/namespace", "r") as f:
                f.read()
    """

def get_parser():
    parser = argparse.ArgumentParser()
    actions_group = parser.add_mutually_exclusive_group(required=True)
    actions_group.add_argument("--cluster-config", action="store_true" , help="Use cluser config. Only applicable when using inside a pod!")
    actions_group.add_argument("--token" , help="Apply a valid API token")

    parser.add_argument("--host", help="The K8s host! including the port. e.g. 192.168.x.x:16443")
    return parser


if __name__ == "__main__":
    main()
