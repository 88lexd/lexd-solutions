from datetime import datetime, timedelta
import boto3
import os
import logging
import sys


def handler(event, context):
    set_logging(log_level='info')

    # Environmental Variables: Can also overwrite manually for quick local testing
    uptime_threshold = int(os.environ['UPTIME_THRESHOLD'])
    notification_threshold = int(os.environ['NOTIFICATION_THRESHOLD'])
    sns_topic_arn = os.environ['SNS_TOPIC_ARN']
    instance_id = os.environ['INSTANCE_ID']

    aws_session = boto3.Session()
    ec2_resource = aws_session.resource('ec2', region_name='ap-southeast-2')
    sns_client = aws_session.client('sns', region_name='ap-southeast-2')

    instance = ec2_resource.Instance(instance_id)

    if instance.state['Name'] == 'stopped':
        logging.info('OK: Instance is stopped! nothing else to do. Script will now exit')
        return {}
    else:
        logging.info("Instance is not in a stopped state. Continuing with the script...")

    # Extract timezone info so datetime.now() can match this object for comparision
    timezone = instance.launch_time.tzinfo
    duration_in_seconds = (datetime.now(timezone) - instance.launch_time).total_seconds()
    last_launch_duration_hours = divmod(duration_in_seconds, 3600)[0]

    if last_launch_duration_hours > uptime_threshold:
        _message = "-- Executing Stop Instance Action --"
        _message += f"\nUptime Threshold: {uptime_threshold} hours"
        _message += f"\nNotification Threshold: {notification_threshold} hours"
        _message += f"\n\nInstance uptime ({last_launch_duration_hours}hrs) exceeded uptime threshold ({uptime_threshold}hrs)!"
        _message += "\nScript is now stopping the instance!'"

        logging.info(_message)

        instance.stop()

        logging.info('Publishing SNS notification...')
        sns_client.publish(TopicArn=sns_topic_arn,
            Subject="Jumpbox uptime exceeded uptime threshold",
            Message=_message)

    elif last_launch_duration_hours > notification_threshold:
        _message = f"-- Notification Only --"
        _message += f"\nUptime Threshold: {uptime_threshold} hours"
        _message += f"\nNotification Threshold: {notification_threshold} hours"
        _message += f"\n\nInstance uptime ({last_launch_duration_hours}hrs) exceeded threshold ({notification_threshold}hrs)!"

        logging.info(_message)

        logging.info('Publishing SNS notification...')
        sns_client.publish(TopicArn=sns_topic_arn,
            Subject="Jumpbox exceeded notification threshold",
            Message="Test message")
    else:
        logging.info("Is within threshold")

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
