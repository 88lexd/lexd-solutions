from botocore.exceptions import ClientError
from datetime import datetime
import enquiries
import argparse
import yaml
import os
import re
import boto3
import configparser


def main():
    print("===================================")
    print("AWS Assume Role Script by Alex Dinh")
    print("===================================")

    parser = get_parser()
    global opts
    opts = parser.parse_args()

    # Check for profile expiry only
    if opts.expiry:
        check_credental_expiry(opts.profile)
        exit(0)

    if not opts.cred_file or not opts.roles_file:
        print("Missing --cred-file and --roles-file!")
        exit(1)

    cred_file = get_full_path_to(opts.cred_file)
    cred = read_config(cred_file)

    roles_file = get_full_path_to(opts.roles_file)
    roles = read_config(roles_file)

    options = generate_menu_options(roles)
    choice = enquiries.choose('Choose a role to assume into: ', options)
    choice_index = get_choice_index(choice)

    if (choice_index == 0):
        print("You have chosen to exit the script.")
        exit(0)

    # Decrement index by 1 (first index was previously used for exit in the menu selection)
    choice_index -= 1
    role = roles[choice_index]

    response = assume_role(cred, role)
    save_credentials(response, cred)

    print("\nYour new AWS credentials will now work with awscli. e.g.")
    print(f"$ aws ec2 describe-instances --profile {opts.profile}")


def get_parser():
    parser = argparse.ArgumentParser(description="Assume role in AWS.")
    parser.add_argument("-p", "--profile", required=True, help="The profile name to save the token")
    parser.add_argument("-c", "--cred-file", help="File containing the AWS credential")
    parser.add_argument("-r", "--roles-file", help="File containing the roles for script to assume-role")
    parser.add_argument("-e", "--expiry", action="store_true", help="Check when a profile expires")
    return parser


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


def read_config(input_file):
    with open(input_file, 'r') as f:
        try:
            config = yaml.load(f, Loader=yaml.BaseLoader)
            return config
        except yaml.YAMLError as exc:
            print(exc)
            raise Exception(f"Cannot parse {input_file} file")


def generate_menu_options(roles):
    menu_list = list()

    menu_list.append("[0] Exit")  # Allow graceful exit from menu, without having to use CTRL+C

    for index, role in enumerate(roles, start=1):
        menu_list.append(f"[{index}] {role['name']} ({role['role_name']}@{role['aws_account_id']})")
    return menu_list


def get_choice_index(choice):
    result = re.findall(r'^\[(\d)+\]', choice)
    return int(result[0])


def assume_role(cred, role):
    iam_mfa_serial = cred['user_arn'].replace(":user/", ":mfa/")
    role_arn = f"arn:aws:iam::{role['aws_account_id']}:role/{role['role_name']}"
    aws_iam_token = input(f"\nEnter MFA token code for [ {cred['user_arn']} ]: ")

    print(f"Assuming role to: {role_arn}")

    sts_client = boto3.Session(
        aws_access_key_id=cred['aws_access_key_id'],
        aws_secret_access_key=cred['aws_secret_access_key'],
        region_name=cred['region']
    ).client('sts')

    try:
      result = sts_client.assume_role(
          RoleArn=role_arn,
          RoleSessionName=role['role_name'],
          SerialNumber=iam_mfa_serial,
          TokenCode=aws_iam_token,
          # DurationSeconds=7200  # 2 hours to match role config. Default is 1hr otherwise
      ).get('Credentials')
    except ClientError as ce:
        print(ce.result)
        exit(1)

    assumed_role_arn = boto3.Session(
        aws_access_key_id=result['AccessKeyId'],
        aws_secret_access_key=result['SecretAccessKey'],
        aws_session_token=result['SessionToken'],
        region_name=cred['region']
    ).client('sts').get_caller_identity()

    print(f"\nSuccessfully assumed role: {assumed_role_arn['Arn']}\n")

    return result


def save_credentials(response, cred):
    global opts

    # Saving to $HOME/.aws/credentials file
    aws_credentials_file = f"{os.getenv('HOME')}/.aws/credentials"
    print(f"Updating {aws_credentials_file} file...")

    CfgParser = configparser.ConfigParser()
    CfgParser.read(aws_credentials_file)

    profile_name = opts.profile

    if profile_name in CfgParser.sections():
        CfgParser.set(profile_name, 'aws_access_key_id', response['AccessKeyId'])
        CfgParser.set(profile_name, 'aws_secret_access_key', response['SecretAccessKey'])
        CfgParser.set(profile_name, 'aws_session_token', response['SessionToken'])
        CfgParser.set(profile_name, 'expiration', str(response['Expiration'].timestamp()))
        CfgParser.set(profile_name, 'region', cred['region'])
    else:
        CfgParser.add_section(profile_name)
        CfgParser.set(profile_name, 'aws_access_key_id', response['AccessKeyId'])
        CfgParser.set(profile_name, 'aws_secret_access_key', response['SecretAccessKey'])
        CfgParser.set(profile_name, 'aws_session_token', response['SessionToken'])
        CfgParser.set(profile_name, 'expiration', str(response['Expiration'].timestamp()))
        CfgParser.set(profile_name, 'region', cred['region'])

    cfgfile = open(aws_credentials_file, 'w')
    CfgParser.write(cfgfile)
    cfgfile.close()


def check_credental_expiry(profile):
    aws_credentials_file = f"{os.getenv('HOME')}/.aws/credentials"
    CfgParser = configparser.ConfigParser()
    CfgParser.read(aws_credentials_file)
    expiration = CfgParser[profile]['expiration']
    expiration_datetime = datetime.fromtimestamp(float(expiration))
    minutes_remaining = int((expiration_datetime - datetime.now()).total_seconds()/60)
    if minutes_remaining > 0:
        print(f"The AWS profile {profile} has {minutes_remaining} minutes remaining")
    else:
        print(f"The AWS profile {profile} has expired {minutes_remaining * -1} minutes ago")

if __name__ == "__main__":
    main()
