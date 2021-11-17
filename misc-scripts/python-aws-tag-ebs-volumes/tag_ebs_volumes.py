import argparse
import boto3
import os


def main():
    print("\n===================================")
    print("AWS Tag EBS volumes by Alex Dinh")
    print("===================================")

    parser = get_parser()
    global opts
    opts = parser.parse_args()

    aws_profile = opts.profile
    aws_region = opts.region
    ebs_volume_id_file = get_full_path_to(opts.file)

    with open(ebs_volume_id_file, 'r') as _f:
        ebs_volume_ids = _f.read().splitlines()

    print("Using the following as script input:")
    print(f"  - AWS Profile: {aws_profile}")
    print(f"  - AWS Region: {aws_region}")
    print(f"  - EBS Volume ID File: {ebs_volume_id_file}")

    if not get_confirmation("\nContinue with the script?"):
        print("\nYou have chosen to stop the script.")
        exit()

    ec2_resource, ec2_client = connect_to_aws(aws_profile, aws_region)

    print(" \nBegin tagging EC2 volumes!")
    _start_tagging_volumes(ec2_resource, ec2_client, ebs_volume_ids)


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


def connect_to_aws(aws_profile, aws_region):
    print("\nConnecting into AWS...")
    try:
        aws_session = boto3.Session(profile_name=aws_profile, region_name=aws_region)
        client = aws_session.client('sts')
        caller_arn = client.get_caller_identity()['Arn']
    except Exception as e:
        print(e)
        exit(1)

    print(f"Successfully connected into AWS using - {caller_arn}")
    ec2_resource = aws_session.resource('ec2', region_name=aws_region)
    ec2_client = aws_session.client('ec2', region_name=aws_region)

    return ec2_resource, ec2_client


def _start_tagging_volumes(ec2_resource, ec2_client, ebs_volume_ids):
    for vol_id in ebs_volume_ids:
        print("================================================================")
        ebs_volume = ec2_resource.Volume(vol_id)

        if ebs_volume.state == 'available':
            # The volume status is 'available', therefore it is not attached to anything
            print(f"Volume ID [{vol_id}] has no attachments")
            continue

        # Based on the attachment, this is the EC2 instance which we need to extract the curent tags from
        instance_id = ebs_volume.attachments[0].get('InstanceId')
        print(f"Volume ID [{vol_id}] is attaced to [{instance_id}]")

        tags_to_tag = get_instance_tags(ec2_client, instance_id)
        tags_to_tag


def get_instance_tags(ec2_client, instance_id):
    instance_tags = ec2_client.describe_tags(
        Filters=[{'Name': 'resource-id', 'Values': [ instance_id ]}]
    )['Tags']

    print(f"\nThe instance [{instance_id}] contains the following tags:")

    # Need to store the tag and values only. ec2_client response contains additional information which is not needed.
    tags = list()
    for tag in instance_tags:
        tag_key = tag['Key']
        tag_value = tag['Value']

        print(f" - {tag_key}: {tag_value}")

        # This data type is required to later tag the volume
        tags.append({
            'Key': tag_key,
            'Value': tag_value
        })

    return tags


def get_confirmation(prompt):
    input_text = input(f"{prompt} (yes/no): ")

    options = { 'yes': True, 'no': False }

    try:
        return options[input_text]
    except KeyError:
        print("Bad input, try again")
        get_confirmation(prompt)


def get_parser():
    parser = argparse.ArgumentParser(description="Assume role in AWS.")
    parser.add_argument("-p", "--profile", required=False, help="The AWS profile name (default is 'default')", default='default')
    parser.add_argument("-r", "--region", required=True, help="The AWS region which the volume ID's are located. e.g. ap-southeast-2")
    parser.add_argument("-f", "--file", required=True, help="File containing the EBS volume ID's")

    return parser


if __name__ == "__main__":
    main()
