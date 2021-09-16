# Terraform Setup
Download and setup Terraform. Run the following:

```bash
$ wget https://releases.hashicorp.com/terraform/1.0.6/terraform_1.0.6_linux_amd64.zip
unzip terraform_1.0.6_linux_amd64.zip
sudo mv terraform /usr/local/bin
terraform -v

# Remove cache
rm terraform_1.0.6_linux_amd64.zip
```

## Setup Provider for AWS
Visit: https://www.terraform.io/docs/language/providers/index.html

Which then takes takes us to https://registry.terraform.io/browse/providers where we can see all the supported providers.

Look for AWS and see how it to install the provider.

Example: *To install this provider, copy and paste this code into your Terraform configuration. Then, run terraform init.*

```
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.58.0"
    }
  }
}
```

Once configured, the providers and modules will be saved to a directory called .terraform/ in this same directory.

e.g. `./.terraform/modules` and `./.terraform/providers`

## Setup backend for tfstate and state locking
By default, the state file is saved locally as `terraform.tfstate`. This is a very bad because if something happens to this file, then we lose the state of our deployed infrastructure.

Locking is also used to make sure multiple users cannot run terraform at the sametime.

The following is used to ensure we are using S3 and DynamoDB as the backend for state and locking.

Reference: https://quileswest.medium.com/how-to-lock-terraform-state-with-s3-bucket-in-dynamodb-3ba7c4e637

Note: The bucket and dynamodb is created by the base-setup.yml (through cloudformation).

```
terraform {
  backend "s3" {
    bucket = "lexd-solutions-tfstate"
    key    = "terraform/tfstate"
    dynamodb_table = "lexd-solutions-tflockstate"
    region = "ap-southeast-2"
  }
}
```


## High Level Requirements (TO DO)
The following will be configured through Terraform
 - VPC
 - Public / Private Subnets
 - Internet Gateway??
 - EIP ??
 - Security Groups
 - SES (free tier -62,000 Outbound Messages per month to any recipient when you call Amazon SES from an Amazon EC2)
 - 1x EC2 to run MicroK8s (t3a.medium (2vCPU and 4GB RAM))
 - Automated EBS snapsots?
