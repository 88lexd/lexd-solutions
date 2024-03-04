import sys
import os
import boto3
import logging
import json


def handler(event, context):
    # print("Received event: " + json.dumps(event, indent=2))
    set_logging(log_level='info')

    logging.debug("Getting event info")
    event_time = event['Records'][0]['eventTime']
    bucket_name = event['Records'][0]['s3']['bucket']['name']
    object_key = event['Records'][0]['s3']['object']['key']

    logging.info("The following object has been uploaded")
    logging.info(f"Event Time: {event_time}")
    logging.info(f"Bucket: {bucket_name}")
    logging.info(f"Object: {object_key}")


    logging.debug("Getting variables from Lambda")
    app_name = os.getenv('APP_NAME')
    deployment_group_name = os.getenv('DEPLOY_GROUP_NAME')

    logging.info(f"Application Name: {app_name}")
    logging.info(f"Deployment Group Name: {deployment_group_name}")


    logging.info("Creating deployment via boto3")
    codedeploy_client = boto3.client('codedeploy')
    deployment = codedeploy_client.create_deployment(
        applicationName=app_name,
        deploymentGroupName=deployment_group_name,
        description='Lambda created deployment from S3',
        revision={
            'revisionType': 'S3',
            's3Location': {
                'bucket': bucket_name,
                'key': object_key,
                'bundleType': 'zip'
            }
        }
    )

    logging.info(deployment)
    logging.info("Deployment created!")

    return {'statusCode': 200}


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
