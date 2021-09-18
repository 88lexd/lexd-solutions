# AWS Update Security Group
Unfortunately I do not have a static public IP address at home and I do not like having SSH open to the world on my security group.

For me to log onto the AWS Console each time I need to SSH onto my instance, it just makes no sense.

This script uses AWS Boto3 and can do 3 things.

 - Add my current public IP for ingress SSH on the security group
 - Remove from my current public IP for ingress SSH on the security
 - Select an ingress rule to remove

## Prerequisite and Setup
Ensure `virtualenv` is installed

```
$ sudo apt install virtualenv
```

Run `setup.sh` to configure Python virtual environment and libraries
```
$ bash setup.sh
<output truncated>
...
Requirement already satisfied: python-dateutil<3.0.0,>=2.1 in ./venv/lib/python3.8/site-packages (from botocore>=1.21.44->-r /home/alex/code/git/lexd-solutions/misc-scripts/python-aws-update-sg/requirements.txt (line 2)) (2.8.2)
Requirement already satisfied: six>=1.5 in ./venv/lib/python3.8/site-packages (from python-dateutil<3.0.0,>=2.1->botocore>=1.21.44->-r /home/alex/code/git/lexd-solutions/misc-scripts/python-aws-update-sg/requirements.txt (line 2)) (1.14.0)

=========================================================================
Append the following line to your bash.rc as an alias for easy script trigger
alias aws-update-sg='/home/alex/code/git/lexd-solutions/misc-scripts/python-aws-update-sg/venv/bin/python3 /home/alex/code/git/lexd-solutions/misc-scripts/python-aws-update-sg/aws-update-sg.py '
```

Append the alias configuration as indicated by the output above (must include the 1 extra space chactacter after .py

You can now run the script by calling `$ aws-update-sg`

## How to use the script
TBD
