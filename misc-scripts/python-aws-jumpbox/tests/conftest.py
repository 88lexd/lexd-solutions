# ./venv/bin/pytest -rA -s --log-cli-level=INFO tests
# or ./venv/bin/pytest -rA -s --log-cli-level=INFO -m start tests

import os, sys
# Add parent path to allow import EC2 module
current_path = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, current_path + '/../')
from modules.ec2 import EC2
import yaml
import pytest
import boto3


def read_config(input_file):
    with open(input_file, 'r') as f:
        try:
            config = yaml.load(f, Loader=yaml.BaseLoader)
            return config
        except yaml.YAMLError as exc:
            print(exc)
            raise Exception(f"Cannot parse {input_file} file")


@pytest.fixture(scope='session')
def ec2_module():
    config = read_config('config.yml')
    print('Setting AWS sesion using EC2 module')
    return EC2(
        aws_profile = config['aws_profile_name'],
        region_name = config['aws_region'],
        instance_id = config['instance_id'],
        sg_id = config['sg_id'])


@pytest.fixture(scope='session')
def ec2_test_session():
    config = read_config('config.yml')
    aws_session = boto3.Session(profile_name=config['aws_profile_name'], region_name=config['aws_region'])
    ec2_resource = aws_session.resource('ec2')
    return ec2_resource
