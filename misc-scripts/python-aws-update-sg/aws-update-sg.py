#!/usr/bin/env python3
import argparse
import sys
import os
from threading import current_thread
import yaml
import boto3
import urllib.request


def main():
    parser = get_parser()
    global opts, ec2
    opts = parser.parse_args()
    ec2 = boto3.resource('ec2')

    _CONFIG = read_config(opts.rule_file)

    if opts.add_rules:
        show_current_ingress_rules(sg_id=_CONFIG['security_group_id'])
        add_rules_to_sg(_CONFIG)

    if opts.remove_rules:
        show_current_ingress_rules(sg_id=_CONFIG['security_group_id'])
        remove_rules_from_sg(_CONFIG)


def read_config(conf_file):
    _CONFIG = dict()
    script_dir = os.path.dirname(os.path.abspath(__file__))
    conf_file = f"{script_dir}/{conf_file}"

    with open(conf_file, 'r') as stream:
        try:
            config = yaml.load(stream, Loader=yaml.BaseLoader)
            for key, value in config.items():
                _CONFIG[key] = value
        except yaml.YAMLError as err:
            print(err)
            raise Exception("Cannot parse config.yml file")

    return _CONFIG


def get_confirmation(prompt):
    input_text = input(f"{prompt} (yes/no): ")

    options = { 'yes': True, 'no': False }

    try:
        return options[input_text]
    except KeyError:
        print("Bad input, try again")
        get_confirmation(prompt)


def add_rules_to_sg(config):
    global ec2
    curent_external_ip = ""

    print(f"\nScript will add the following rules into - {config['security_group_id']}")
    for rule in config['ingress_rules']:
        if rule['source_cidr'] == 'USE_CURRENT_PUBLIC_IP':
            curent_external_ip = f"{get_current_public_ip()}/32"
            print(f"  Protcol: {rule['protocol']} | From Port: {rule['from_port']} | To Port: {rule['to_port']} | Source (current): {curent_external_ip} | Description: {config['rule_description']}")
        else:
            print(f"  Protcol: {rule['protocol']} | From Port: {rule['from_port']} | To Port: {rule['to_port']} | Source: {rule['source_cidr']} | Description: {config['rule_description']}")


    if not get_confirmation("\nContinue with the script?"):
        print("You have chosen to stop the script.")
        exit()

    security_group = ec2.SecurityGroup(config['security_group_id'])

    print("Updating security group...")
    for rule in config['ingress_rules']:
        if rule['source_cidr'] == 'USE_CURRENT_PUBLIC_IP':
            source_cidr = curent_external_ip
        else:
            source_cidr = rule['source_cidr']

        security_group.authorize_ingress(
            IpPermissions=[
                {
                    'IpProtocol': rule['protocol'],
                    'FromPort': int(rule['from_port']),
                    'ToPort': int(rule['to_port']),
                    'IpRanges': [{ 'CidrIp': source_cidr, 'Description': config['rule_description'] }]
                }
            ]
        )

    print("Update completed!")


def remove_rules_from_sg(config):
    global ec2

    print(f"\nScript will remove the rules where description == {config['rule_description']}")
    if not get_confirmation("Continue with the script?"):
        print("You have chosen to stop the script.")
        exit()

    security_group = ec2.SecurityGroup(config['security_group_id'])

    for rule in security_group.ip_permissions:
        for ip_range in rule['IpRanges']:
            if ip_range.get('Description') == config['rule_description']:
                print(f"  Removing -- Protcol: {rule['IpProtocol']} | From Port: {rule['FromPort']} | To Port: {rule['ToPort']} | Source: {ip_range['CidrIp']}")
                security_group.revoke_ingress(
                    IpPermissions=[
                        {
                            'IpProtocol': rule['IpProtocol'],
                            'FromPort': rule['FromPort'],
                            'ToPort': rule['ToPort'],
                            'IpRanges': [{ 'CidrIp': ip_range['CidrIp'], 'Description': ip_range['Description'] }],
                        }
                    ]
                )
    print("All ingress rules matching description has been removed!")


def show_current_ingress_rules(sg_id):
    global ec2
    security_group = ec2.SecurityGroup(sg_id)
    print(f"Displaying current ingress rules for - {sg_id} (only showing rules where 'source' is an IP CIDR)")
    for rule in security_group.ip_permissions:
        print(f"  Protcol: {rule['IpProtocol']} | From Port: {rule['FromPort']} | To Port: {rule['ToPort']} | Source: {rule['IpRanges']}")


def get_current_public_ip():
    external_ip = urllib.request.urlopen('https://ifconfig.me').read().decode('utf8')
    return external_ip


def get_parser():
    def _make_wide(formatter, w=120, h=100):
        try:
            kwargs = {'width': w, 'max_help_position': h}
            formatter(None, **kwargs)
            return lambda prog: formatter(prog, **kwargs)
        except TypeError:
            print("argparse help formatter failed, falling back.")
            return formatter

    description = "Script to update a single AWS security group using a locally defined config file"
    parser = argparse.ArgumentParser(description=description,
                                     formatter_class=_make_wide(argparse.ArgumentDefaultsHelpFormatter))

    # Exclusive actions for script
    actions_group = parser.add_mutually_exclusive_group(required=True)
    actions_group.add_argument("--add-rules", action="store_true" , help="Add rules into security group")
    actions_group.add_argument("--remove-rules", action="store_true" , help="Remove rules into security group")

    # Options for script
    parser.add_argument("--rule-file", required=True, help="yaml file which defines the SG rules to add/remove")

    return parser


if __name__ == "__main__":
    main()
