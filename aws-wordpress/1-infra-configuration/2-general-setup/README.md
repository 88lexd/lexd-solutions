# IMPORTANT: Prerequisites
Before continuing running the general setup, the following must be done first

 - Applied `cfn-base-setup.yml` (CloudFormation base setup)
   - This will setup the VPC, S3 and DynamoDB etc.
 - Manually setup keypair under EC2 Console and refected the key name in `variables.tf`
   - This must be done manually so you can download the private key during creation.
 - Manually allocate EIP (Elastic IP) under VPC Console and reflect the "Allocation ID" in `variables.tf`
   - Rather not create the EIP via Terraform in case a `terraform destroy` will permanently delete the allocated IP for the production use.

One the above is done, then continue with the below

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
$ wget https://releases.hashicorp.com/terraform/1.0.6/terraform_1.0.6_linux_amd64.zip
unzip terraform_1.0.6_linux_amd64.zip
sudo mv terraform /usr/local/bin
terraform -v

# Remove cache
rm terraform_1.0.6_linux_amd64.zip
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
**IMPORTANT** - Must fix up later!!

The above is NOT very secure! My credentials are saved locally on my machine and it does not expire! Later on I will need to setup a role which requires MFA and then have a script that can perform the assume role function to retrieve a temporary token via STS

## Run Terraform
After setting up the above, can now run Terraform to apply the template.
```
$ terraform init
$ terraform plan
$ terraform apply
```


# High Level Requirements (TO DO)
The following will be configured through Terraform
 - [x] VPC
 - [x] Public / Private Subnets
 - [x] Internet Gateway
 - [x] EIP
 - [x] Security Groups
 - [x] 1x EC2 to run MicroK8s (t3a.medium (2vCPU and 4GB RAM))
 - [x] Automated EBS snapsots
