# Notify When Jumpbox Uptime Exceeded Threshold
Background: In my new design, I have a dedicated EC2 jumpbox instance running on AWS for me to manage my servers.

To learn more about it, see my blog post here: https://lexdsolutions.com/2022/01/replacing-microk8s-with-kubernetes-cluster-created-by-kubeadm/

## Why I created this
As I don't always access my EC2 jumpbox, having it running 24/7 is a waste of money. So each time I need to manage my cluster, I use another script which I've written to power-on the instance and then power it off when I am done with it.

If you want to know more about this script, you can find it here: https://github.com/88lexd/lexd-solutions/tree/main/misc-scripts/python-aws-jumpbox

The problem I have with this is if I ever forget to run the stop command, my instance will remain in a running state and time = money.

## My Options
I could use the CloudWatch agent to push the instance uptime to CloudWatch and create an alarm if the uptime is greater than my threshold then send out a notification, however I rather prefer to write my own Lambda function as I can re-use this piece of code othe other projects later on.

## How it works
CloudWatch will trigger my Lambda function every hour and will do the following:
 - If the jumpbox instance is running for more than the "NOTIFICATION_THRESHOLD", then send out a notification via SNS.
 - If the jumpbox instance is running for more than the "UPTIME_THRESHOLD", then **stop** the instance and send out a notification via SNS.

# How This is Deployed
## Custom GitHub Container Action
When I make changes to `main.py` in the ./src directory, GitHub Actions will detect this and will execute the [lambda-to-s3-jumpbox-uptime](https://github.com/88lexd/lexd-solutions/blob/main/.github/workflows/lambda-to-s3-jumpbox-uptime.yml) workflow which will:

1) Zip up the main.py
2) Use the custom Docker container action to push the artifact up to S3

## Deploy using Terraform
Once the code is pushed to S3 via GitHub Actions, use the terraform template to deploy the resources.

**Note**: The Lambda Terraform resource uses the S3 object version_id, what this means is if there is a new object that is pushed by GitHub Actions, Terraform will detect this and will update the Lambda function.

```
$ terraform init
$ terraform apply
```

The Terraform template will configure the following resources:
 - Lambda Function using the S3 object
 - IAM roles and policies for the Lambda function
 - CloudWatch/EventBridge rules to trigger the Lambda function hourly

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.66.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3.66.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.lambda_trigger_event_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.lambda_trigger_event_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_group.log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_policy.lambda_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.iam_for_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.lambda_policy_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.lambda_function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.cloudwatch_invoke_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_instance.jumpbox](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/instance) | data source |
| [aws_s3_bucket_object.lambda_zip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_bucket_object) | data source |
| [aws_sns_topic.general_notification_topic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/sns_topic) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region to create these resources | `string` | n/a | yes |
| <a name="input_cw_event_name"></a> [cw\_event\_name](#input\_cw\_event\_name) | The name for the CloudWatch/EventBridge name (name is used in the lambda\_policy\_json) | `string` | n/a | yes |
| <a name="input_cw_event_schedule"></a> [cw\_event\_schedule](#input\_cw\_event\_schedule) | The cron schedule for the CW event | `string` | n/a | yes |
| <a name="input_jumpbox_instance_name"></a> [jumpbox\_instance\_name](#input\_jumpbox\_instance\_name) | The name tag of the jumpbox instance | `string` | n/a | yes |
| <a name="input_lambda_cw_logs_retention"></a> [lambda\_cw\_logs\_retention](#input\_lambda\_cw\_logs\_retention) | CloudWatch logs retention in days for the Lambda function | `number` | n/a | yes |
| <a name="input_lambda_environment_variables"></a> [lambda\_environment\_variables](#input\_lambda\_environment\_variables) | The environmental variables used by the Lambda function. Threshold is in hours | <pre>object({<br>    UPTIME_THRESHOLD       = number<br>    NOTIFICATION_THRESHOLD = number<br>  })</pre> | n/a | yes |
| <a name="input_lambda_func_description"></a> [lambda\_func\_description](#input\_lambda\_func\_description) | Description for the Lambda function | `string` | n/a | yes |
| <a name="input_lambda_func_name"></a> [lambda\_func\_name](#input\_lambda\_func\_name) | Name of the Lambda function | `string` | n/a | yes |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | The name of the S3 bucket that contains the fuction code | `string` | n/a | yes |
| <a name="input_s3_lambda_zip"></a> [s3\_lambda\_zip](#input\_s3\_lambda\_zip) | The object (zip) where the Lambda code is stored | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->