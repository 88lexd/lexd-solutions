from kubernetes import client, config
from datetime import datetime, timedelta
import argparse
import check_cert
import os
import logging
import debugpy


def main():
    parser = _get_parser()
    global opts
    opts = parser.parse_args()

    config.load_incluster_config()
    networking_api = client.ExtensionsV1beta1Api()

    with open('/var/run/secrets/kubernetes.io/serviceaccount/namespace', 'r') as f:
        k8s_namespace = f.read()

    if opts.ingress_hosts:
        ingress_hosts_response = networking_api.list_namespaced_ingress(k8s_namespace)

    debugpy.listen(5678)
    print("Waiting for debugger attach")
    debugpy.wait_for_client()
    debugpy.breakpoint()
    print(ingress_hosts_response)

    all_hosts = list()
    for ingress in ingress_hosts_response.items:
        ingress.spec['rules']



# Using args so can support other checks later. e.g. hostnames from a DynamoDB table or an S3 object.
def _get_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument("--ingress-hosts", action="store_true" , help="Check all ingress hosts URLs")
    return parser


if __name__ == "__main__":
    main()
