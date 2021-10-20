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

    expiring_certs, invalid_certs, failed_checks = check_certs(all_hosts)
    build_email_body(all_hosts, expiring_certs, invalid_certs, failed_checks)


def check_certs(all_hosts):
    days_threshold = int(os.environ['DAYS_REMAINING_THRESHOLD'])
    # days_threshold = 180
    expiring_certs = list()
    invalid_certs = list()
    failed_checks = list()

    for host in all_hosts:
        logging.info(f"Checking URL [{host}] for TLS certifcate...")
        endpoint_cert = check_cert.get_certificate(url=host)

        if endpoint_cert is None:
            # Allow skip and continue to check next URL
            logging.warning("WARNING: Unable check the TLS certificate!")
            failed_checks.append({
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
            logging.info(f"OK: Certificate has more than {days_threshold} days before it expires. (expires on {expire_date})")
        elif until_expire.days <= days_threshold and endpoint_cert['cert_valid']:
            logging.info(f"WARNING: Certificate is expiring in {until_expire.days} days! (threshold: {days_threshold} days) (expiring on {expire_date})")

            # Append extra info into response
            endpoint_cert.update({'days_until_expire': until_expire.days})
            endpoint_cert.update({'expire_date_str': expire_date})

            expiring_certs.append({
                'url': host,
                'cert_status': 'ok',
                'cert': endpoint_cert
            })
        elif not endpoint_cert['cert_valid']:
            logging.info("WARNING: Certificate is not valid!")
            invalid_certs.append({
                'url': host,
                'cert_status': 'invalid',
                'cert': endpoint_cert
            })
        else:
            logging.error("ERROR: Unknown status for the certificate!")
            logging.debug(endpoint_cert)
            exit(2)

    return expiring_certs, invalid_certs, failed_checks


def build_email_body(all_hosts, expiring_certs, invalid_certs, failed_checks):
    # debugpy.listen(5678)
    # print("Waiting for debugger attach")
    # debugpy.wait_for_client()
    # debugpy.breakpoint()

    _expiring_certs = [ i['cert'] for i in expiring_certs ]
    _invalid_certs = [ i['cert'] for i in invalid_certs ]
    _failed_checks = [ i['url'] for i in failed_checks ]

    templateLoader = FileSystemLoader(searchpath=f"{SCRIPT_DIR}/email_templates/")
    templateEnv = Environment(loader=templateLoader, autoescape=True)
    template = templateEnv.get_template("email.j2")
    template_output = template.render(
        days_threshold=int(os.environ['DAYS_REMAINING_THRESHOLD']),
        all_hosts=all_hosts,
        expiring_certs=_expiring_certs,
        invalid_certs=_invalid_certs,
        failed_checks=_failed_checks
    )

    with open(f'{SCRIPT_DIR}/email_body.html', 'w') as _f:
        _f.write(template_output)


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
