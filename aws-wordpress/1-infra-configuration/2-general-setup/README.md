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

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | >= 2.2.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | >= 2.2.0 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_kubeadm_cluster"></a> [kubeadm\_cluster](#module\_kubeadm\_cluster) | ./kubeadm_cluster | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | 3.7.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.codedeploy_lambda_log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_metric_alarm.per_instance_alarms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_codedeploy_app.henry_todo_app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codedeploy_app) | resource |
| [aws_codedeploy_deployment_group.henry_todo_deploy_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codedeploy_deployment_group) | resource |
| [aws_dlm_lifecycle_policy.dlm_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dlm_lifecycle_policy) | resource |
| [aws_iam_openid_connect_provider.github_oidc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_role.codedeploy_lambda_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.codedeploy_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.dlm_lifecycle_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.github_oidc_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.dlm_lifecycle](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_user.github_ci_to_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user_policy.github_ci_to_s3_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy) | resource |
| [aws_lambda_function.codedeploy_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.allow_codedeploy_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_s3_bucket.codedeploy_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.lambda_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.codedeploy_s3_bucket_acl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_acl.lambda_s3_bucket_acl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_lifecycle_configuration.codedeploy_s3_bucket_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_lifecycle_configuration.lambda_s3_bucket_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_notification.codedeploy_s3_notification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification) | resource |
| [aws_s3_bucket_public_access_block.s3_bucket_block_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_versioning.codedeploy_s3_bucket_versioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_versioning.lambda_s3_bucket_config_versioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [archive_file.codedeploy_lambda_zip](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_instance.k8s_master](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/instance) | data source |
| [aws_instance.k8s_worker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/instance) | data source |
| [aws_sns_topic.cw_alarm_topic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/sns_topic) | data source |
| [tls_certificate.github_actions](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/data-sources/certificate) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region to create these resources | `string` | n/a | yes |
| <a name="input_codedeploy_s3_bucket_name"></a> [codedeploy\_s3\_bucket\_name](#input\_codedeploy\_s3\_bucket\_name) | Name for the S3 bucket to store codedeploy artifacts. This is where GitHub Actions will drop the archives | `string` | n/a | yes |
| <a name="input_cw_log_k8s_application_retention"></a> [cw\_log\_k8s\_application\_retention](#input\_cw\_log\_k8s\_application\_retention) | The number of days to keep the application logs in CloudWatch | `number` | n/a | yes |
| <a name="input_cw_log_k8s_dataplane_retention"></a> [cw\_log\_k8s\_dataplane\_retention](#input\_cw\_log\_k8s\_dataplane\_retention) | The number of days to keep the dataplane logs in CloudWatch | `number` | n/a | yes |
| <a name="input_dlm_copy_tags"></a> [dlm\_copy\_tags](#input\_dlm\_copy\_tags) | Copy all user-defined tags on a source volume to the snapshot created by DLM | `bool` | `true` | no |
| <a name="input_dlm_retain_count"></a> [dlm\_retain\_count](#input\_dlm\_retain\_count) | Number of snapshots to retain | `number` | `7` | no |
| <a name="input_dlm_schedule_interval"></a> [dlm\_schedule\_interval](#input\_dlm\_schedule\_interval) | Interval for the schdeule | `number` | `24` | no |
| <a name="input_dlm_schedule_name"></a> [dlm\_schedule\_name](#input\_dlm\_schedule\_name) | Name for the DLM schedule | `string` | n/a | yes |
| <a name="input_dlm_schedule_time"></a> [dlm\_schedule\_time](#input\_dlm\_schedule\_time) | When the policy should be evaluated. | `list(string)` | n/a | yes |
| <a name="input_dlm_schedule_unit"></a> [dlm\_schedule\_unit](#input\_dlm\_schedule\_unit) | Unit for the schedule interval | `string` | `"HOURS"` | no |
| <a name="input_dlm_tags_to_add"></a> [dlm\_tags\_to\_add](#input\_dlm\_tags\_to\_add) | Extra tags to add | <pre>object({<br>    SnapshotCreator = string<br>  })</pre> | <pre>{<br>  "SnapshotCreator": "DLM"<br>}</pre> | no |
| <a name="input_dlm_target_tags"></a> [dlm\_target\_tags](#input\_dlm\_target\_tags) | Volumes with these tags will be targetted by DLM to take snapshots | <pre>object({<br>    Snapshot = string<br>  })</pre> | <pre>{<br>  "Snapshot": "True"<br>}</pre> | no |
| <a name="input_ec2_ami_name"></a> [ec2\_ami\_name](#input\_ec2\_ami\_name) | Name of the AMI to use (wild card to search all but will use most recent) | `string` | n/a | yes |
| <a name="input_ec2_ami_owner_id"></a> [ec2\_ami\_owner\_id](#input\_ec2\_ami\_owner\_id) | Owner ID of the AMI | `string` | n/a | yes |
| <a name="input_ec2_k8smaster_instance_name"></a> [ec2\_k8smaster\_instance\_name](#input\_ec2\_k8smaster\_instance\_name) | Name for the K8s master instance | `string` | n/a | yes |
| <a name="input_ec2_k8smaster_instance_tags"></a> [ec2\_k8smaster\_instance\_tags](#input\_ec2\_k8smaster\_instance\_tags) | Tags to attach to the K8s Master instance | `map(string)` | n/a | yes |
| <a name="input_ec2_k8smaster_instance_type"></a> [ec2\_k8smaster\_instance\_type](#input\_ec2\_k8smaster\_instance\_type) | Instance type | `string` | n/a | yes |
| <a name="input_ec2_k8sworker_instance_name"></a> [ec2\_k8sworker\_instance\_name](#input\_ec2\_k8sworker\_instance\_name) | Name for the K8s worker instance | `string` | n/a | yes |
| <a name="input_ec2_k8sworker_instance_tags"></a> [ec2\_k8sworker\_instance\_tags](#input\_ec2\_k8sworker\_instance\_tags) | Tags to attach to the K8s Worker instances | `map(string)` | n/a | yes |
| <a name="input_ec2_k8sworker_instance_type"></a> [ec2\_k8sworker\_instance\_type](#input\_ec2\_k8sworker\_instance\_type) | Instance type | `string` | n/a | yes |
| <a name="input_ec2_keypair_name"></a> [ec2\_keypair\_name](#input\_ec2\_keypair\_name) | Key Pair name (must already exist!) | `string` | n/a | yes |
| <a name="input_github_actions_url"></a> [github\_actions\_url](#input\_github\_actions\_url) | The GitHub Actions URL for OIDC | `string` | n/a | yes |
| <a name="input_github_source_repo"></a> [github\_source\_repo](#input\_github\_source\_repo) | The source repo for OIDC using format <accountname>/<repo\_name> | `string` | n/a | yes |
| <a name="input_iam_role_name_for_ec2"></a> [iam\_role\_name\_for\_ec2](#input\_iam\_role\_name\_for\_ec2) | The name of the IAM role that is attached to the EC2 instance | `string` | n/a | yes |
| <a name="input_jumpbox_sg_id"></a> [jumpbox\_sg\_id](#input\_jumpbox\_sg\_id) | Security group that is attached to the jumpbox | `string` | n/a | yes |
| <a name="input_lambda_s3_bucket_name"></a> [lambda\_s3\_bucket\_name](#input\_lambda\_s3\_bucket\_name) | Name for the S3 bucket to store Lambda zip files. This is where GitHub Actions will drop the archives | `string` | n/a | yes |
| <a name="input_vpc_azs"></a> [vpc\_azs](#input\_vpc\_azs) | AZs to use for this region | `list(string)` | n/a | yes |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR for the VPC | `string` | `"10.0.0.0/16"` | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | Name of the VPC | `string` | n/a | yes |
| <a name="input_vpc_private_subnets"></a> [vpc\_private\_subnets](#input\_vpc\_private\_subnets) | CIDRs for private subnets | `list(string)` | n/a | yes |
| <a name="input_vpc_public_subnets"></a> [vpc\_public\_subnets](#input\_vpc\_public\_subnets) | CIDRs for public subnets | `list(string)` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->