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
4) Update the local .ssh/config file with the current public IP of the EC2 instance. This is required for VS Code to perform remote SSH into the jumpbox.

# The Script
## Prerequisites
First execute `setup.sh` to install the required modules under a Python virtual environment. Also setup the bash alias for easy script trigger.

Example:
```
$ bash setup.sh
created virtual environment CPython3.8.10.final.0-64 in 83ms
  creator CPython3Posix(dest=/home/alex/code/git/lexd-solutions/misc-scripts/python-aws-jumpbox/venv, clear=False, global=False)
  seeder FromAppData(download=False, pip=latest, setuptools=latest, wheel=latest, pkg_resources=latest, via=copy, app_data_dir=/home/alex/.local/share/virtualenv/seed-app-data/v1.0.1.debian.1)
  activators BashActivator,CShellActivator,FishActivator,PowerShellActivator,PythonActivator,XonshActivator
Collecting boto3
  Downloading boto3-1.20.33-py3-none-any.whl (131 kB)
  ...
Collecting pyyaml
  Using cached PyYAML-6.0-cp38-cp38-manylinux_2_5_x86_64.manylinux1_x86_64.manylinux_2_12_x86_64.manylinux2010_x86_64.whl (701 kB)
Processing /home/alex/.cache/pip/wheels/a0/16/9c/5473df82468f958445479c59e784896fa24f4a5fc024b0f501/termcolor-1.1.0-py3-none-any.whl
Collecting jmespath<1.0.0,>=0.7.1
  Using cached jmespath-0.10.0-py2.py3-none-any.whl (24 kB)
Collecting s3transfer<0.6.0,>=0.5.0
  Using cached s3transfer-0.5.0-py3-none-any.whl (79 kB)
Collecting botocore<1.24.0,>=1.23.33
  Downloading botocore-1.23.33-py3-none-any.whl (8.5 MB)
  ...
Collecting urllib3<1.27,>=1.25.4
  Using cached urllib3-1.26.8-py2.py3-none-any.whl (138 kB)
Collecting python-dateutil<3.0.0,>=2.1
  Using cached python_dateutil-2.8.2-py2.py3-none-any.whl (247 kB)
Collecting six>=1.5
  Using cached six-1.16.0-py2.py3-none-any.whl (11 kB)
Installing collected packages: jmespath, urllib3, six, python-dateutil, botocore, s3transfer, boto3, pyyaml, termcolor
Successfully installed boto3-1.20.33 botocore-1.23.33 jmespath-0.10.0 python-dateutil-2.8.2 pyyaml-6.0 s3transfer-0.5.0 six-1.16.0 termcolor-1.1.0 urllib3-1.26.8

=========================================================================
Append the following line to your .bashrc as an alias for easy script trigger
alias aws-jumpbox='/home/alex/code/git/lexd-solutions/misc-scripts/python-aws-jumpbox/venv/bin/python3 /home/alex/code/git/lexd-solutions/misc-scripts/python-aws-jumpbox/jumpbox.py '
```

Secondly, for VS Code to use Remote SSH to the jumpbox, this script will also update the .ssh/config file with the current instance's public IP.

The script uses regex to do this. It is important that the .ssh/config file contains the host called 'aws-jumpbox' then follow by the HostName configuration. Example:

```
# Note: I am using WSL on Windows
$ cat /mnt/c/Users/Alex/.ssh/config
Host aws-jumpbox
    HostName w.x.y.z
    User ubuntu
    IdentityFile "C:\Users\Alex\.ssh\my-key.pem"
```

## How to Run the Script
The below assumes that there is a working AWS credential configured under `~/.aws/credentials`.

### Setup config.yml file
Make a copy of `config.yml.template` and call it `config.yml`

Update `config.yml` to contain the relevant settings such as instance id, security group id etc.

### Starting the Jumpbox
To start the jumpbox, pass in `--start` to the script.

**Note**: Once the instance is started, the script has an option to update the .ssh/config file. This file is used by VS Code so I can access the Jumpbox through "Remote SSH".

Example:
```
$ aws-jumpbox --file config.yml --start
===============================
AWS Jumpbox Script by Alex Dinh
===============================
Found the instance using id [i-0a67xxx]

-----------------
Tags on Instance:
-----------------
Name: Jumpbox

------------------------
Instance State: STOPPED
------------------------

Start the instance? (yes/no): yes
Starting the instance...
Instance State: pending
Instance State: running
Instance started successfully! (public IP: 52.63.xx.yy)

Update security group? (yes/no): yes
Updating security group...
Getting current outbound public IP...
  Current External IP: 49.195.xx.yy
Updating security group ingress rules...
Displaying ingress rules for - sg-0db4xxx
  Protcol: tcp | From Port: 22 | To Port: 22 | Source: [{'CidrIp': '49.195.xx.yy/32', 'Description': 'MyDynamicIP'}]
Security group updated successfully!

Update .ssh/config file? (yes/no): yes
Updating .ssh/config file
Config updated!

Script completed!
```

### Stopping the Jumpbox
To stop the jumpbox, pass in `--stop` to the script. Once the instance is stopped, there is an option to clean the ingress security group rules.

Example:
```
$ aws-jumpbox --file config.yml --stop
===============================
AWS Jumpbox Script by Alex Dinh
===============================
Found the instance using id [i-0a674f430ae92d9a2]

-----------------
Tags on Instance:
-----------------
Name: Jumpbox

------------------------
Instance State: RUNNING
------------------------

Stop the instance? (yes/no): yes
Stopping the instance...
Instance State: stopping
Instance State: stopping
Instance State: stopped
Instance stopped successfully!

Clean security group rule(s)? (yes/no): yes
Cleaning security group rules with description [MyDynamicIP]...
  Removing -- Protcol: tcp | From Port: 22 | To Port: 22 | Source: 49.195.xx.yy/32
Security group cleaning completed!

Script completed!
```
