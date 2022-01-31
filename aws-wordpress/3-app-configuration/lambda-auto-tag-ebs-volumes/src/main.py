import boto3
import json
import logging
import sys


def handler(event, context):
    set_logging(log_level='info')

    aws_session = boto3.session.Session()
    curent_region = aws_session.region_name

    if curent_region != event['region']:
        logging.warning(f"Current Region: {curent_region} does not match event region: {event['region']}")
        logging.info("Script is now exiting")
        return {}

    ec2_client = aws_session.client('ec2', region_name=curent_region)

    instance_id = event['detail']['requestParameters']['instanceId']
    volume_id = event['detail']['requestParameters']['volumeId']

    tags_to_tag = get_instance_tags(ec2_client, instance_id)

    logging.info(f"Tagging volume [{volume_id}]")
    ec2_client.create_tags( Resources=[volume_id], Tags=tags_to_tag)

    logging.info("Script completed!")
    return {}


def set_logging(log_level):
    root = logging.getLogger()
    if root.handlers:
        for handler in root.handlers:
            root.removeHandler(handler)

    logging.basicConfig(format='%(asctime)s %(levelname)s %(filename)s[%(lineno)d]: %(message)s',
                        datefmt='%d/%m/%Y %I:%M:%S %p',
                        stream=sys.stdout,
                        level=getattr(logging, log_level.upper()))

    logging.getLogger('requests').setLevel(logging.WARNING)
    logging.getLogger("urllib3").setLevel(logging.WARNING)


def get_instance_tags(ec2_client, instance_id):
    instance_tags = ec2_client.describe_tags(
        Filters=[{'Name': 'resource-id', 'Values': [ instance_id ]}]
    )['Tags']

    logging.info(f"The instance [{instance_id}] contains the following tags:")

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
