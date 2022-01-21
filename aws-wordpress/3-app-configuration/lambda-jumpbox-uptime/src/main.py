from datetime import datetime, timedelta
import boto3
import os


def handler(event, context):
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
        print('OK: Instance is stopped! nothing else to do. Script will now exit')
        exit(0)
    else:
        print("Instance is not in a stopped state. Continuing with the script...")

    # Extract timezone info so datetime.now() can match this object for comparision
    timezone = instance.launch_time.tzinfo
    duration_in_seconds = (datetime.now(timezone) - instance.launch_time).total_seconds()
    last_launch_duration_hours = divmod(duration_in_seconds, 3600)[0]

    if last_launch_duration_hours > uptime_threshold:
        _message = f"""-- Executing Stop Instance Action --
Uptime Threshold: {uptime_threshold} hours
Notification Threshold: {notification_threshold} hours

Instance uptime ({last_launch_duration_hours}hrs) exceeded uptime threshold ({uptime_threshold}hrs)!"
Script is now stopping the instance!'"""

        print(_message)

        instance.stop()

        print('Publishing SNS notification...')
        sns_client.publish(TopicArn=sns_topic_arn,
            Subject="Jumpbox uptime exceeded uptime threshold",
            Message=_message)

    elif last_launch_duration_hours > notification_threshold:
        _message = f"""-- Notification Only --
Uptime Threshold: {uptime_threshold} hours
Notification Threshold: {notification_threshold} hours

Instance uptime ({last_launch_duration_hours}hrs) exceeded threshold ({notification_threshold}hrs)!"""
        print(_message)

        print('Publishing SNS notification...')
        sns_client.publish(TopicArn=sns_topic_arn,
            Subject="Jumpbox exceeded notification threshold",
            Message="Test message")
    else:
        print("Is within threshold")

    print("Script completed!")
