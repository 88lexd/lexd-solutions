# AWS Update Security Group
Unfortunately I do not have a static public IP address at home and I do not like having SSH open to the world on my security group.

For me to log onto the AWS Console to update the security group each time I need to SSH onto my instance, it just makes no sense.

This script uses AWS Boto3 and can do 2 things.

 - Add ingress rules from config file into existing security group
 - Remove the "script created ingress rules" from the security group

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

# How to use the script
There are 2 functions of this script, add rule and remove rules.
## Adding Rule
Make a copy of `sg-rules.yml.template` and call it `sg-rules.yml`.

Modify the yaml file with the rules as desired.

*Note: "source_cidr: USE_CURRENT_PUBLIC_IP" means to allow script to find the current public IP and use that as source CIDR!*

Example:
```
$ aws-update-sg --add-rules --rule-file sg-rules.yml
Displaying current ingress rules for - sg-091d91a3132ebef48 (only showing rules where 'source' is an IP CIDR)
  Protcol: tcp | From Port: 80 | To Port: 80 | Source: [{'CidrIp': '0.0.0.0/0', 'Description': 'Allow HTTP'}]
  Protcol: tcp | From Port: 443 | To Port: 443 | Source: [{'CidrIp': '0.0.0.0/0', 'Description': 'Allow HTTPS'}]

Script will add the following rules into - sg-091d91a3132ebef48
  Protcol: tcp | From Port: 22 | To Port: 22 | Source (current): 49.179.xx.yy/32 | Description: Testing 123
  Protcol: tcp | From Port: 22 | To Port: 22 | Source: 0.0.0.0/0 | Description: Testing 123

Continue with the script? (yes/no): yes
Updating security group...
Update completed!
```

## Removing Rule
The script will delete ingress rules which matches the `rule_description:` in the yml file.
Example:
```
$ aws-update-sg --remove-rules --rule-file sg-rules.yml
Displaying current ingress rules for - sg-091d91a3132ebef48 (only showing rules where 'source' is an IP CIDR)
  Protcol: tcp | From Port: 80 | To Port: 80 | Source: [{'CidrIp': '0.0.0.0/0', 'Description': 'Allow HTTP'}]
  Protcol: tcp | From Port: 22 | To Port: 22 | Source: [{'CidrIp': '49.179.xx.yy/32', 'Description': 'Testing 123'}, {'CidrIp': '0.0.0.0/0', 'Description': 'Testing 123'}]
  Protcol: tcp | From Port: 443 | To Port: 443 | Source: [{'CidrIp': '0.0.0.0/0', 'Description': 'Allow HTTPS'}]

Script will remove the rules where description == Testing 123
Continue with the script? (yes/no): yes
  Removing -- Protcol: tcp | From Port: 22 | To Port: 22 | Source: 49.179.xx.yy/32
  Removing -- Protcol: tcp | From Port: 22 | To Port: 22 | Source: 0.0.0.0/0
All ingress rules matching description has been removed!
```
