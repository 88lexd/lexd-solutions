# Base Setup on AWS
The base setup creates the following resources (assuming the AWS account is newly created with nothing else configured but the root user).

 - 1x IAM User (best practice to not use the root account)
 - 1x S3 bucket for Terraform states
    - Ensure versioning and lifecycle management is setup
 - 1x DynamoDB table for Terraform state and locking
 - Admin Role and permissions (allow IAM user to assume into role for extra security)

All other infrastructure is created using Terraform. I have chosen to use CloudFormation here is because I don't want to manually create any resources including the S3 bucket and the DynamoDB used by Terraform. I also cannot use Terraform to create these resources due to the "chicken and egg" problem.

To deploy this for a new account is as simple as uploading the `cfn-base-setup.yml` file into CloudFormation with the root account.

## Update existing stack via CLI
This is for my own reference. Can be handy to update this stack using the CLI later on, much easier than uploading the file through the GUI each time.

```
aws cloudformation update-stack --stack-name "base-setup" \
   --template-body file://cfn-base-setup.yml \
   --capabilities CAPABILITY_NAMED_IAM \
   --parameters ParameterKey=IAMUsername,UsePreviousValue=true \
      ParameterKey=IAMUserPassword,UsePreviousValue=true \
      ParameterKey=TerraformStateBucketName,UsePreviousValue=true \
      ParameterKey=TerraformStateTableName,UsePreviousValue=true
```
