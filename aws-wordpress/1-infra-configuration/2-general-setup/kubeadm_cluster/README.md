<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ec2_instance"></a> [ec2\_instance](#module\_ec2\_instance) | terraform-aws-modules/ec2-instance/aws | 3.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.k8s_application](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.k8s_dataplane](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_efs_file_system.k8s_efs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system) | resource |
| [aws_efs_mount_target.k8s_efs_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_mount_target) | resource |
| [aws_iam_instance_profile.ec2_iam_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.kubeadm_ec2_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_security_group.efs_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.k8s_master](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.k8s_workernodes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.k8s_master_ingress_rules](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.k8s_worker_kubelet_ingress_rules](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_ami.ubuntu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_codedeploy_bucket_arn"></a> [codedeploy\_bucket\_arn](#input\_codedeploy\_bucket\_arn) | The ARN of the CodeDeploy S3 bucket. It is used to grant access to the EC2 IAM role | `string` | n/a | yes |
| <a name="input_cw_log_k8s_application_retention"></a> [cw\_log\_k8s\_application\_retention](#input\_cw\_log\_k8s\_application\_retention) | The number of days to keep the application logs in CloudWatch | `number` | n/a | yes |
| <a name="input_cw_log_k8s_dataplane_retention"></a> [cw\_log\_k8s\_dataplane\_retention](#input\_cw\_log\_k8s\_dataplane\_retention) | The number of days to keep the dataplane logs in CloudWatch | `number` | n/a | yes |
| <a name="input_ec2_ami_name"></a> [ec2\_ami\_name](#input\_ec2\_ami\_name) | Name of the AMI to use (wild card to search all but will use most recent) | `string` | n/a | yes |
| <a name="input_ec2_ami_owner_id"></a> [ec2\_ami\_owner\_id](#input\_ec2\_ami\_owner\_id) | Owner ID of the AMI | `string` | n/a | yes |
| <a name="input_ec2_k8smaster_instance_name"></a> [ec2\_k8smaster\_instance\_name](#input\_ec2\_k8smaster\_instance\_name) | Name for the K8s master instance | `string` | n/a | yes |
| <a name="input_ec2_k8smaster_instance_tags"></a> [ec2\_k8smaster\_instance\_tags](#input\_ec2\_k8smaster\_instance\_tags) | Tags to attach to the K8s Master instance | `map(string)` | n/a | yes |
| <a name="input_ec2_k8smaster_instance_type"></a> [ec2\_k8smaster\_instance\_type](#input\_ec2\_k8smaster\_instance\_type) | Instance type | `string` | n/a | yes |
| <a name="input_ec2_k8sworker_instance_name"></a> [ec2\_k8sworker\_instance\_name](#input\_ec2\_k8sworker\_instance\_name) | Name for the K8s worker instance | `string` | n/a | yes |
| <a name="input_ec2_k8sworker_instance_tags"></a> [ec2\_k8sworker\_instance\_tags](#input\_ec2\_k8sworker\_instance\_tags) | Tags to attach to the K8s Worker instances | `map(string)` | n/a | yes |
| <a name="input_ec2_k8sworker_instance_type"></a> [ec2\_k8sworker\_instance\_type](#input\_ec2\_k8sworker\_instance\_type) | Instance type | `string` | n/a | yes |
| <a name="input_ec2_keypair_name"></a> [ec2\_keypair\_name](#input\_ec2\_keypair\_name) | Key Pair name (must already exist!) | `string` | n/a | yes |
| <a name="input_iam_role_name_for_ec2"></a> [iam\_role\_name\_for\_ec2](#input\_iam\_role\_name\_for\_ec2) | The name of the IAM role that is attached to the EC2 instance | `string` | n/a | yes |
| <a name="input_jumpbox_sg_id"></a> [jumpbox\_sg\_id](#input\_jumpbox\_sg\_id) | Security group that is attached to the jumpbox | `string` | n/a | yes |
| <a name="input_vpc_azs"></a> [vpc\_azs](#input\_vpc\_azs) | List of AZs | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID | `string` | n/a | yes |
| <a name="input_vpc_private_subnets"></a> [vpc\_private\_subnets](#input\_vpc\_private\_subnets) | List of private subnets | `list(string)` | n/a | yes |
| <a name="input_vpc_public_subnets"></a> [vpc\_public\_subnets](#input\_vpc\_public\_subnets) | List of public subnets | `list(string)` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->