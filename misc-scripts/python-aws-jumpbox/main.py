from modules.ec2 import EC2
from termcolor import colored
import argparse
import yaml
import os
import re


def main():
    print("===============================")
    print("AWS Jumpbox Script by Alex Dinh")
    print("===============================")

    parser = get_parser()
    opts = parser.parse_args()

    config_file = get_full_path_to(opts.file)
    _CONFIG = read_config(config_file)

    global ec2
    ec2 = EC2(
        aws_profile=_CONFIG['aws_profile_name'],
        region_name=_CONFIG['aws_region'],
        instance_id=_CONFIG['instance_id'],
        sg_id=_CONFIG['sg_id'])

    ec2.instance_status()

    if opts.start:
        if get_confirmation('\nStart the instance?'):
            print(f"{colored('Starting the instance...', 'green')}")
            ec2.start_instance()

        if get_confirmation('\nUpdate security group?'):
            print(f"{colored('Updating security group...', 'green')}")
            ec2.update_security_group(_CONFIG['sg_ingress_rules'], _CONFIG['sg_rule_description'])

        if get_confirmation('\nUpdate .ssh/config file?'):
            print(f"{colored('Updating .ssh/config file', 'green')}")
            update_ssh_config(_CONFIG['ssh_config_file'], ec2.get_public_ip())

    if opts.stop:
        if get_confirmation('\nStop the instance?'):
            print(f"{colored('Stopping the instance...', 'yellow')}")
            ec2.stop_instance()

        if get_confirmation('\nClean security group rule(s)?'):
            msg = f"Cleaning security group rules with description [{_CONFIG['sg_rule_description']}]..."
            print(colored(msg, 'yellow'))
            ec2.clean_security_group_rules(_CONFIG['sg_rule_description'])

    print("\nScript completed!")


def update_ssh_config(config_file, public_ip_addr):
    with open(config_file, 'r') as f:
        ssh_config_file = f.read()

    regexp = r'(Host\s+aws-jumpbox\s+HostName)\s+(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})'
    updated_config = re.sub(regexp, rf'\1 {public_ip_addr}', ssh_config_file)

    with open(config_file, 'w') as f:
        f.write(updated_config)

    print("Config updated!")


def get_confirmation(prompt):
    input_text = input(f"{prompt} (yes/no): ")

    options = { 'yes': True, 'no': False }

    try:
        return options[input_text]
    except KeyError:
        print("Bad input, try again")
        get_confirmation(prompt)


def read_config(input_file):
    with open(input_file, 'r') as f:
        try:
            config = yaml.load(f, Loader=yaml.BaseLoader)
            return config
        except yaml.YAMLError as exc:
            print(exc)
            raise Exception(f"Cannot parse {input_file} file")


def get_full_path_to(input_path):
    script_dir = os.path.dirname(os.path.abspath(__file__))
    file_name = input_path.split('/')[-1]

    # First check if is next to the script file
    if os.path.exists(f'{script_dir}/{file_name}'):
        return f'{script_dir}/{file_name}'
    # Check the actual input path
    elif (os.path.exists(input_path)):
        return input_path
    else:
        raise FileNotFoundError


def get_parser():
    parser = argparse.ArgumentParser(description="Start/Stop AWS Jumpbox")

    group = parser.add_mutually_exclusive_group()  # only allows one or the other to be configured
    group.add_argument("--start", action="store_true", help="Start the EC2 instance")
    group.add_argument("--stop", action="store_true", help="Start the EC2 instance")

    parser.add_argument("-f", "--file", required=True, help="File containing the config")

    return parser


if __name__ == "__main__":
    main()
