# Why I've developed this script?
Read my blog post here to know why I've developed this script in the first place.

URL: https://lexdsolutions.com/2021/09/how-to-assume-role-on-aws-and-using-python/

# AWS - AssumeRole
Using a privileged account to log directly into AWS is not a good security practice. This is almost like using the root account to log onto a Linux machine.

On Linux, it is best practice to use sudo under a standard user. This should also apply to AWS when managing cloud resources.

Lastly, what would you do if you only have IAM users (e.g. no SSO like ADFS or Okta) and you have a dozen AWS accounts to manage? You wouldn't want to create an IAM user for each of those accounts do you!?

By using assume roles you can have a single IAM user and this user can assume role into all the various AWS accounts that you manage.

## What is AssumeRole?
AssumeRole on AWS allows you to temporarily get security credentials into a different role. The role assuming into will generally provide more privileged access.

You can also assume into a role to a completely different AWS account. More about this topic is discussed on my blog.

## Prerequisite and Setup
- Ensure you have the IAM "access and secret keys" handy. This will be required later to setup the credential config file.

- Ensure `virtualenv` is installed

  ```
  $ sudo apt install virtualenv
  ```

- Run `setup.sh` to configure Python virtual environment and libraries
  ```
  $ bash setup.sh
  <output truncated>
  ...
  Successfully installed blessings-1.7 boto3-1.18.49 botocore-1.21.49 configparser-5.0.2 curtsies-0.3.7 cwcwidth-0.1.4 enquiries-0.1.0 jmespath-0.10.0 python-dateutil-2.8.2 pyyaml-5.4.1 s3transfer-0.5.0

  =============================================================================
  Append the following line to your .bashrc as an alias for easy script trigger
  =============================================================================
  alias assume-role='/home/alex/code/git/lexd-solutions/misc-scripts/python-aws-assume-role/venv/bin/python3 /home/alex/code/git/lexd-solutions/misc-scripts/python-aws-assume-role/assume-role.py '
  ```

  **Important Note**: There an extra space after .py and before the ending quote!

  As indicated by the script output above. Setup the alias in your .bashrc and then source the file by running `source ~/.bashrc`



## How to Use the Script
- Make a copy of `cred.yml.template` and call it `cred.yml`. You can put this file anywhere you like.

- Populate the `cred.yml` file with your standard IAM user details. Example:
  ```
  ---
  user_arn: arn:aws:iam::<12345>:user/<username>
  region: ap-southeast-2
  aws_access_key_id: <your aws access key>
  aws_secret_access_key: <your aws secret key>
  ```

- Make a copy of `role.yml.template` and call it `roles.yml`. You can put this file anywhere you like.

- Populate the `roles.yml` file with the possible roles which you have access to assume into.
  ```
  ---
  # The name is for the description used the script menu
  # role_name is case sensitive!
  - name: My Admin Role
    aws_account_id: 12345
    role_name: My-Admin-Role

  # The script supports connecting to another AWS account.
  # As long as the target account role allows you to assume into that role.
  - name: My NonAdmin Role
    aws_account_id: 56789
    role_name: My-Admin-Role
  ```
  **Important Note**: The role_name is case sensitive!


- Execute the script by passing in the config files
  ```
  $ assume-role --cred-file ~/cred.yml --roles-file ~/roles.yml --profile alex
  or
  $ assume-role --c ~/cred.yml -r ~/roles.yml -p alex

  ===================================
  AWS Assume Role Script by Alex Dinh
  ===================================
  Choose a role to assume into:
    [0] Exit
  > [1] My Admin Role (My-Admin@12345)
    [2] My NonAdmin Role (My-NonAdmin@56789)

  Enter MFA token code for [ arn:aws:iam::12345:user/myusername ]: 123456

  Assuming role to: arn:aws:iam::12345:role/My-Admin
  Successfully assumed role!
  Updating /home/alex/.aws/credentials file...

  Your new AWS credentials will now work with awscli. e.g.
  $ aws ec2 describe-instances --profile alex
  ```

- Can now run awscli commands by specifying the profile you created
  ```
  $ aws ec2 describe-instances --profile alex | jq '.Reservations[].Instances[].InstanceId'
  "i-02bfd9dafcfxxxxxx"
  ```

- To check STS token expiry run the following:
  ```
  $ assume-role --profile alex --expiry
  or
  $ assume-role --p alex -e
  ===================================
  AWS Assume Role Script by Alex Dinh
  ===================================
  The AWS profile alex has 59 minutes remaining
  ```
