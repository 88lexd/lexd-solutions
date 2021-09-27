from botocore.exceptions import ClientError
import enquiries
import argparse
import yaml
import os
import re
import boto3
import configparser


def main():
    parser = get_parser()
    global opts
    opts = parser.parse_args()

    cred_file = get_full_path_to(opts.cred_file)
    cred = read_config(cred_file)

    roles_file = get_full_path_to(opts.roles_file)
    roles = read_config(roles_file)

    options = generate_menu_options(roles)
    choice = enquiries.choose('Choose one of these options: ', options)
    choice_index = get_choice_index(choice)

    if (choice_index == 0):
        print("You have chosen to exit the script.")
        exit(0)

    # Decrement index by 1 (first index was previously used for exit in the menu selection)
    choice_index -= 1
    role = roles[choice_index]

    response = assume_role(cred, role)
    save_credentials_file(response, cred)

    print("\nYour new AWS credentials will now work with awscli. e.g.")
    print("$ aws ec2 describe-instances --profile %s" % opts.profile)


def get_parser():
    parser = argparse.ArgumentParser(description="Assume role in AWS.")
    parser.add_argument("-c", "--cred-file", required=True, help="File containing the AWS credential")
    parser.add_argument("-r", "--roles-file", required=True, help="File containing the roles for script to assume-role")
    parser.add_argument("-p", "--profile", required=True, help="The profile name to save the token")
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
        menu_list.append(f"[{index}] {role['name']} ({role['role']}@{role['aws_account_id']})")
    return menu_list


def get_choice_index(choice):
    result = re.findall(r'^\[(\d)+\]', choice)
    return int(result[0])


def assume_role(cred, role):
    iam_mfa_serial = cred['user_arn'].replace(":user/", ":mfa/")
    role_arn = f"arn:aws:iam::{role['aws_account_id']}:role/{role['role']}"
    aws_iam_token = input(f" Enter MFA token code for [ {cred['user_arn']} ]: ")

    print("Assuming role to: %s" % role_arn)

    session = boto3.Session(
        aws_access_key_id=cred['aws_access_key_id'],
        aws_secret_access_key=cred['aws_secret_access_key'],
        region_name=cred['region'])

    sts_client = session.client('sts')

    try:
      response = sts_client.assume_role(
          RoleArn=role_arn,
          RoleSessionName=role['role'],
          SerialNumber=iam_mfa_serial,
          TokenCode=aws_iam_token
      ).get('Credentials')
    except ClientError as ce:
        print(ce.response)
        exit(1)

    target_session = boto3.Session(
        aws_access_key_id=response['AccessKeyId'],
        aws_secret_access_key=response['SecretAccessKey'],
        aws_session_token=response['SessionToken'],
        region_name=cred['region']
    )

    assumed_role_arn = target_session.client('sts').get_caller_identity()
    print("\nSuccessfully assumed role: %s\n" % assumed_role_arn['Arn'])

    return response


def save_credentials_file(response, cred):
    global opts

    # Saving to $HOME/.aws/credentials file
    aws_credentials_file = f"{os.getenv('HOME')}/.aws/credentials"
    print(f"Updating {aws_credentials_file} file...")

    Config = configparser.ConfigParser()
    Config.read(aws_credentials_file)

    profile_name = opts.profile

    if profile_name in Config.sections():
        Config.set(profile_name, 'aws_access_key_id', response['AccessKeyId'])
        Config.set(profile_name, 'aws_secret_access_key', response['SecretAccessKey'])
        Config.set(profile_name, 'aws_session_token', response['SessionToken'])
        Config.set(profile_name, 'expiration', str(response['Expiration'].timestamp()))
        Config.set(profile_name, 'region', cred['region'])
    else:
        Config.add_section(profile_name)
        Config.set(profile_name, 'aws_access_key_id', response['AccessKeyId'])
        Config.set(profile_name, 'aws_secret_access_key', response['SecretAccessKey'])
        Config.set(profile_name, 'aws_session_token', response['SessionToken'])
        Config.set(profile_name, 'expiration', str(response['Expiration'].timestamp()))
        Config.set(profile_name, 'region', cred['region'])
    cfgfile = open(aws_credentials_file, 'w')
    Config.write(cfgfile)
    cfgfile.close()


if __name__ == "__main__":
    main()
