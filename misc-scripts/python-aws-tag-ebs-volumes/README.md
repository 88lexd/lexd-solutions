# Tag EBS Volumes
Script to tag EBS volumes by using the tag information from the EC2 instance which it is attached to.

## Install and Activate Boto3 in a Virtual Environment
First install boto3 module if not yet already installed.

Note: If you already have Boto3 available system wide, then this step can be skipped
```
$ virtualenv -p python3 venv
$ ./venv/bin/python3 -m pip install boto3
$ source ./bin/activate
```

