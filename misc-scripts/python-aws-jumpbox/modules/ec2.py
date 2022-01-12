from botocore.exceptions import ClientError
from termcolor import colored
import urllib.request
import boto3
import time


class EC2:
    def __init__(self, aws_profile='default', region_name=None, instance_id=None, sg_id=None):
        self.aws_session = boto3.Session(profile_name=aws_profile, region_name=region_name)
        self.ec2_client = self.aws_session.client('ec2', region_name=region_name)
        self.ec2_resource = self.aws_session.resource('ec2', region_name=region_name)
        self.instance_id = instance_id
        self.security_group_id = sg_id

        try:
            self.aws_session.client('sts').get_caller_identity()
        except ClientError as e:
            print("\nFailed connecting to AWS!")
            print(e.response['Error']['Message'])
            exit(1)


    def instance_status(self):
        instance = self.ec2_resource.Instance(self.instance_id)

        if not instance:
            print(f"ERROR: Unable to locate instance using [{self.instance_id}]")
            exit(1)

        print(f"Found the instance using id [{self.instance_id}]")

        print("\n-----------------")
        print("Tags on Instance:")
        print("-----------------")
        for tag in instance.tags:
            print(f"{tag['Key']}: {tag['Value']}")

        instance_state = instance.state['Name'].upper()
        print("\n------------------------")
        print(f"Instance State: {colored(instance_state, 'red', 'on_yellow')}")
        print("------------------------")


    def stop_instance(self):
        instance = self.ec2_resource.Instance(self.instance_id)
        instance.stop()

        while instance.state['Name'] != 'stopped':
            instance = self.ec2_resource.Instance(self.instance_id)
            print(f"Instance State: {instance.state['Name']}")
            time.sleep(5)
        print('Instance stopped successfully!')


    def start_instance(self):
        instance = self.ec2_resource.Instance(self.instance_id)
        instance.start()

        while instance.state['Name'] != 'running':
            instance = self.ec2_resource.Instance(self.instance_id)
            print(f"Instance State: {instance.state['Name']}")
            time.sleep(5)
        print('Instance started successfully!')


    def get_public_ip(self):
        instance = self.ec2_resource.Instance(self.instance_id)
        return instance.public_ip_address


    def update_security_group(self, ingress_rules, rule_description):
        security_group = self.ec2_resource.SecurityGroup(self.security_group_id)

        print(f"Displaying current ingress rules for - {self.security_group_id} (only showing rules where 'source' is an IP CIDR)")
        for rule in security_group.ip_permissions:
            print(f"  Protcol: {rule['IpProtocol']} | From Port: {rule['FromPort']} | To Port: {rule['ToPort']} | Source: {rule['IpRanges']}")

        print("Getting current outbound public IP...")
        external_ip = urllib.request.urlopen('https://ifconfig.me').read().decode('utf8')

        print(f"  Current External IP: {external_ip}")

        print("Updating security group ingress rules...")
        for rule in ingress_rules:
            if rule['source_cidr'] == 'USE_CURRENT_PUBLIC_IP':
                source_cidr = f'{external_ip}/32'
            else:
                source_cidr = rule['source_cidr']

            try:
                security_group.authorize_ingress(
                    IpPermissions=[
                        {
                            'IpProtocol': rule['protocol'],
                            'FromPort': int(rule['from_port']),
                            'ToPort': int(rule['to_port']),
                            'IpRanges': [{ 'CidrIp': source_cidr, 'Description': rule_description }]
                        }
                    ]
                )
            except ClientError as ce:
                if ce.response['Error']['Code'] == 'InvalidPermission.Duplicate':
                    print(f"  Warning: {ce.response['Error']['Message']}")
                else:
                    raise

        print("Security group updated successfully!")


    def clean_security_group_rules(self, rule_description):
        security_group = self.ec2_resource.SecurityGroup(self.security_group_id)

        for rule in security_group.ip_permissions:
            for ip_range in rule['IpRanges']:
                if ip_range.get('Description') == rule_description:
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
        print("Security group cleaning completed!")
