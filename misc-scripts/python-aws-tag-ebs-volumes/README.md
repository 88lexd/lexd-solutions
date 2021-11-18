# Tag EBS Volumes
Script to tag EBS volumes by using the tag information from the EC2 instance which it is attached to.

## Install and Activate Boto3 in a Virtual Environment
First install boto3 module if not yet already installed.

Note: If you already have Boto3 available system wide, then this step can be skipped
```
$ virtualenv -p python3 venv
$ ./venv/bin/python3 -m pip install boto3
$ source ./venv/bin/activate 
```

## How to Run the Script
First create a file that contains the volume IDs (note: volumes must all reside in the same region!)

Example:
```
$ cat /tmp/volumes.txt
vol-03075aac92c018501
vol-0adb09fd484746be8
```

Execute the script. Example:

```
$ source ./venv/bin/activate
(venv) $ python3 tag_ebs_volumes.py --region ap-southeast-2 --file /tmp/volumes.txt --profile alex

===================================
AWS Tag EBS volumes by Alex Dinh
===================================
Using the following as script input:
  - AWS Profile: alex
  - AWS Region: ap-southeast-2
  - EBS Volume ID File: /tmp/volumes.txt

Continue with the script? (yes/no): yes

Connecting into AWS...
Successfully connected into AWS using - arn:aws:sts::123456789123:assumed-role/LEXD-Admin/LEXD-Admin

Begin tagging EC2 volumes!
================================================================
Volume ID [vol-03075aac92c018501] is attached to [i-0c748ea843e7ab6f5]

The instance [i-0c748ea843e7ab6f5] contains the following tags:
 - Department: Awesome Department
 - Environment: Production
 - Name: TinyInstance
Tagging volume
Tagging volume completed!
================================================================
Volume ID [vol-0adb09fd484746be8] has no attachments
Skipped tagging this volume

Script completed!
```
