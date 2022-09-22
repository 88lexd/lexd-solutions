# IMPORTANT: Prerequisites
Before continuing, run the general setup. The following must be done first

 - Applied `cfn-base-setup.yml` (CloudFormation base setup)
   - This will setup S3 and DynamoDB etc.
 - Manually setup keypair under EC2 Console and reflect the key name in `var-input.auto.tfvars`
   - This must be done manually so you can download the private key during creation.
 - Manually allocate EIP (Elastic IP) under VPC Console and reflect the "Allocation ID" in `var-input.auto.tfvars`
   - Rather not create the EIP via Terraform in case a `terraform destroy` will permanently delete the allocated IP for the production use.

Once the above is done, then continue with the below

# How to run this

## Install AWSCLI
Will require AWSCLI to interface with AWS.

```bash
$ curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
$ unzip awscliv2.zip
$ sudo ./aws/install

$ aws --version

# Remove cache
$ rm awscliv2.zip
$ rm -rf ./aws
```
## Install Terraform
Download and setup Terraform. Run the following:

```bash
$ curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
$ sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
$ sudo apt-get update && sudo apt-get install terraform
```

## Configure AWS Cred
First log onto AWS (IAM user, do not use root), create Access Keys, then run the following command to save it

```bash
$ aws configure
AWS Access Key ID [None]: AKIA...
AWS Secret Access Key [None]: G4gb...
Default region name [None]: ap-southeast-2
Default output format [None]: json

# This will create a default credential and saves this to
$ ls ~/.aws/{credentials,config}
```
**IMPORTANT**

The above is NOT very secure! My credentials are saved locally on my machine and it does not expire! Instead, should use assume roles! see my blog post here: https://lexdsolutions.com/2021/09/how-to-assume-role-on-aws-and-using-python/

Once role is assumed, then run the followin to allow the shell to know which profile to use. e.g.
```
$ export AWS_PROFILE=alex
```

## Run Terraform
After setting up the above, can now run Terraform to apply the template.
```
$ terraform init
$ terraform plan
$ terraform apply
```

# What this stack creates
The following will be configured through Terraform
 - VPC
 - Public / Private Subnets
 - Internet Gateway
 - 3x Security Groups (Master node, Worker node & EFS)
 - 2x EC instances (1x Master and 1x Worker node)
 - Automated EBS snapsots via DLM Lifecycle
 - Various IAM roles and permissions
 - CloudWatch Alarms
 - LogGroups for fluentbit used by K8s
 - S3 buckets for Lambdas and CodeDeploy
 - CodeDeploy (app and deployment group)
