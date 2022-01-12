# AWS Jumpbox
I don't always access my jumpbox on AWS and therefore it is often left in a stopped state to save cost.

## Challenges
I have the following challenges which I need to overcome.

1) Not using EIP (Elastic IP) - Unassociated EIP's have a cost involved, so witout this, each time the jumpbox is started it will receive a different public IP.
2) No static IP from my ISP - This is previously solved by writing my own custom script. I will be reusing the script here with some modification. Read my [blog post](https://lexdsolutions.com/2021/09/aws-dynamic-public-ip-problem-with-security-groups/) here to learn more.

So to work around these challenges, I need a script that can:
1) Start the EC2 instance
2) Get the current public IP of the instance
3) Update the AWS security group with my current public IP
4) Update the local .ssh/config with the current public IP of the EC2 instance

# The Script
## Install and Activate Boto3 in a Virtual Environment
First install boto3 module if not yet already installed.

Note: If you already have Boto3 available system wide, then this step can be skipped
```
$ virtualenv -p python3 venv
$ ./venv/bin/python3 -m pip install boto3 pyyaml termcolor
$ source ./venv/bin/activate
```

## How to Execute



