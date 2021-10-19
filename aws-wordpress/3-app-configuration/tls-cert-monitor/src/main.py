from kubernetes import client, config
from jinja2 import Environment, FileSystemLoader
from datetime import datetime
import argparse
import check_cert
import sys
import os
import logging
import debugpy


SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))


def main():
    parser = _get_parser()
    global opts
    opts = parser.parse_args()

    set_logging(log_level=opts.logging)

    all_hosts = list()

    config.load_incluster_config()
    networking_api = client.ExtensionsV1beta1Api()

    with open('/var/run/secrets/kubernetes.io/serviceaccount/namespace', 'r') as f:
        k8s_namespace = f.read()

    if opts.ingress_hosts:
        ingress_hosts_response = networking_api.list_namespaced_ingress(k8s_namespace)
        for ingress in ingress_hosts_response.items:
            all_hosts.extend([host.host for host in ingress.spec.rules])

    if len(all_hosts) < 1:
        logging.warning("No hostnames found from the ingress rules!")
        exit(1)



    invalid_or_expiring_certs = check_certs(all_hosts)
    debugpy.listen(5678)
    print("Waiting for debugger attach")
    debugpy.wait_for_client()
    debugpy.breakpoint()

    build_email_body(invalid_or_expiring_certs)


def check_certs(all_hosts):
    days_threshold = int(os.environ['DAYS_REMAINING_THRESHOLD'])
    invalid_or_expiring_certs = list()

    for host in all_hosts:
        logging.info(f"Checking URL [{host}] for TLS certifcate...")
        endpoint_cert = check_cert.get_certificate(url=host)

        if endpoint_cert is None:
            # Allow skip and continue to check next URL
            logging.warning("WARNING: Unable check the TLS certificate!")
            invalid_or_expiring_certs.append({
                'url': host,
                'cert_status': 'failed'
            })
            continue

        date_now = datetime.now()
        cert_expire_date = endpoint_cert['not_after_date']
        expire_date = "{day}/{month}/{year}".format(day=cert_expire_date.day,
                                                    month=cert_expire_date.month,
                                                    year=cert_expire_date.year)
        until_expire = cert_expire_date - date_now

        if until_expire.days > days_threshold and endpoint_cert['cert_valid']:
            logging.info(f"OK: Certificate has more than 30 days before it expires. (expires on {expire_date})")
            invalid_or_expiring_certs.append({
                'url': host,
                'cert_status': 'ok',
                'cert': endpoint_cert
            })
        elif until_expire.days <= days_threshold and endpoint_cert['cert_valid']:
            logging.info(f"WARNING: Certificate is expiring in {until_expire.days} days! (expires on {expire_date})")
            invalid_or_expiring_certs.append({
                'url': host,
                'cert_status': 'ok',
                'cert': endpoint_cert
            })
        elif not endpoint_cert['cert_valid']:
            logging.info("WARNING: Certificate is not valid!")
            invalid_or_expiring_certs.append({
                'url': host,
                'cert_status': 'invalid',
                'cert': endpoint_cert
            })
        else:
            logging.error("ERROR: Unknown status for the certificate!")
            logging.debug(endpoint_cert)
            exit(2)

    return invalid_or_expiring_certs


def build_email_body(invalid_or_expiring_certs):
    days_threshold = int(os.environ['DAYS_REMAINING_THRESHOLD'])

    templateLoader = FileSystemLoader(searchpath=f"{SCRIPT_DIR}/email_templates/")
    templateEnv = Environment(loader=templateLoader, autoescape=True)
    template = templateEnv.get_template("template.html")
    outputText = template.render(
    name="alex",
    url="https://lexdsolutions.com"
    )


    with open('final.html', 'w') as _f:
        _f.write(outputText)


def _get_parser():
    parser = argparse.ArgumentParser(description="Script to check TLS certificate expiry")

    # Logging options
    logging_choices = ['critical', 'error', 'warning', 'info','debug']
    group = parser.add_mutually_exclusive_group()  # only allows one or the other to be used
    group.add_argument("--logging", choices=logging_choices, default='info' ,help="Sets logging level")
    group.add_argument("-q", "--quiet", action="store_true", help="Disables logging (overwrites logging setting)")

    parser.add_argument("--ingress-hosts", action="store_true" , help="Check all ingress hosts URLs")
    return parser


def set_logging(log_level):
    logging.basicConfig(format='%(asctime)s %(levelname)s %(filename)s[%(lineno)d]: %(message)s',
                        datefmt='%d/%m/%Y %I:%M:%S %p',
                        stream=sys.stdout,
                        level=getattr(logging, log_level.upper()))
    logging.getLogger('requests').setLevel(logging.WARNING)
    logging.getLogger("urllib3").setLevel(logging.WARNING)


if __name__ == "__main__":
    main()
