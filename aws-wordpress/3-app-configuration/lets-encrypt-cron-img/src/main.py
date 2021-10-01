from kubernetes import client, config
from kubernetes.client.rest import ApiException
import kubernetes.client
import argparse


def main():
    parser = get_parser()
    global opts
    opts = parser.parse_args()

    if opts.cluster_config:
        config.load_incluster_config()
        kclient = client.CoreV1Api()
    else:
        configuration = kubernetes.client.Configuration()
        configuration.api_key['authorization'] = opts.token
        configuration.api_key_prefix['authorization'] = 'Bearer'
        configuration.host = "https://192.168.198.101:16443"
        configuration.verify_ssl=False

        # Enter a context with an instance of the API kubernetes.client
        with kubernetes.client.ApiClient(configuration) as api_client:
            kclient = kubernetes.client.CoreV1Api(api_client)


    ret = kclient.read_namespaced_secret('mysql-dev', 'dev')
    print(ret)


def get_parser():
    parser = argparse.ArgumentParser()
    actions_group = parser.add_mutually_exclusive_group(required=True)
    actions_group.add_argument("--cluster-config", action="store_true" , help="Use cluser config. Only applicable when using inside a pod!")
    actions_group.add_argument("--token" , help="Apply a valid API token")
    return parser


if __name__ == "__main__":
    main()
