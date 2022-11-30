# Auto Tag EBS Volumes When is Attached to an Instance
**Background**: This is a follow up from my previous blog post where I've developed a script to tag EBS volumes by using the attached instance tags.

In the original script, it takes in a text file of volume IDs and it will tag those volumes only. To know more, check out my blog post here: https://lexdsolutions.com/2021/11/aws-tagging-ebs-volumes-by-using-the-attached-instance-tags/

While this works, it is not very efficient as each time there are untagged volumes, we must run the script manually.

## What's New
I've developed a Lambda function which will automatically tag the EBS volume when it is being attached to the target instance.

How it works:
1. EventBridge monitors the CloudTrail API calls
2. When there is an API event that matches the following event pattern:
    ```
    {
      "source": ["aws.ec2"],
      "detail-type": ["AWS API Call via CloudTrail"],
      "detail": {
        "eventSource": ["ec2.amazonaws.com"],
        "eventName": ["AttachVolume"]
      }
    }
    ```
    EventBridge will trigger the Lambda function and pass in the event details such as the volume and instance id.
3. Lambda will tag the EBS volume by using the target instance tags.


## How to Deploy This
First modify the `variables.tf` file

Then deploy the Terraform template:
```
$ terraform init
$ terraform plan
$ terraform apply
```

### Troubleshooting
For any issues during deployment, I find that cleaning the stack and redeploying works pretty well for me.
```
$ terraform apply -destroy
```

## Dev Notes
### Auto Deploy to S3 for Terraform/Lambda
When changes are made to `./src/**`, GitHub workflow will be triggered and will zip the main.py then upload it to S3.

Reference: https://github.com/88lexd/lexd-solutions/blob/main/.github/workflows/lambda-to-s3-auto-tag-ebs.yml

### Local Testing
The easiest way to work with CloudWatch/EventBridge with CloudTrail is to first go into CloudTrail and view the "event record" from there. This way you know what is expected when it is passed in as the 'detail' object from CloudWatch into Lambda.

From here, we can simulate our own local event object to test the function locally before loading it onto AWS.
```
# main.py

event = """
{
  "version": "0",
  "id": "3089a2a3-316f-1195-89b6-88ba74db0b03",
  "detail-type": "AWS API Call via CloudTrail",
  "source": "aws.ec2",
  "account": "68261xxxxxxx",
  "time": "2022-01-31T00:52:51Z",
  "region": "ap-southeast-2",
  "resources": [

  ],
  "detail": {
    "eventVersion": "1.08",
    "userIdentity": {
      "type": "AssumedRole",
      "principalId": "AROAZ53XONxxxx:alex",
      "arn": "arn:aws:sts::68261xxxxxxx:assumed-role/LEXD-Admin/alex",
      "accountId": "68261xxxxxxx",
      "accessKeyId": "ASIAZ53xxxxx",
      "sessionContext": {
        "sessionIssuer": {
          "type": "Role",
          "principalId": "AROAZ53XONxxxx",
          "arn": "arn:aws:iam::68261xxxxxxx:role/LEXD-Admin",
          "accountId": "68261xxxxxxx",
          "userName": "LEXD-Admin"
        },
        "webIdFederationData": {
        },
        "attributes": {
          "creationDate": "2022-01-31T00:01:17Z",
          "mfaAuthenticated": "true"
        }
      }
    },
    "eventTime": "2022-01-31T00:52:51Z",
    "eventSource": "ec2.amazonaws.com",
    "eventName": "AttachVolume",
    "awsRegion": "ap-southeast-2",
    "sourceIPAddress": "49.195.XXX.YYY",
    "userAgent": "console.ec2.amazonaws.com",
    "requestParameters": {
      "volumeId": "vol-0e89d6e0cceb33115",
      "instanceId": "i-0a674f430ae92d9a2",
      "device": "/dev/sdf",
      "deleteOnTermination": false
    },
    "responseElements": {
      "requestId": "c34427ac-8579-4ef5-a649-5387de0ff54f",
      "volumeId": "vol-0e89d6e0cceb33115",
      "instanceId": "i-0a674f430ae92d9a2",
      "device": "/dev/sdf",
      "status": "attaching",
      "attachTime": 1643590371083,
      "deleteOnTermination": false
    },
    "requestID": "c34427ac-8579-4ef5-a649-5387de0ff54f",
    "eventID": "fc03b7a2-c8f1-434b-8169-a005d1946e9b",
    "readOnly": false,
    "eventType": "AwsApiCall",
    "managementEvent": true,
    "recipientAccountId": "68261xxxxxxx",
    "eventCategory": "Management",
    "sessionCredentialFromConsole": "true"
  }
}
"""

handler(json.loads(event),"")
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 3.66.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.66.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.lambda_trigger_event_rule](https://registry.terraform.io/providers/hashicorp/aws/3.66.0/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.lambda_trigger_event_target](https://registry.terraform.io/providers/hashicorp/aws/3.66.0/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_group.log_group](https://registry.terraform.io/providers/hashicorp/aws/3.66.0/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_policy.lambda_policy](https://registry.terraform.io/providers/hashicorp/aws/3.66.0/docs/resources/iam_policy) | resource |
| [aws_iam_role.iam_for_lambda](https://registry.terraform.io/providers/hashicorp/aws/3.66.0/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.lambda_policy_attach](https://registry.terraform.io/providers/hashicorp/aws/3.66.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.lambda_function](https://registry.terraform.io/providers/hashicorp/aws/3.66.0/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.cloudwatch_invoke_lambda](https://registry.terraform.io/providers/hashicorp/aws/3.66.0/docs/resources/lambda_permission) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/3.66.0/docs/data-sources/caller_identity) | data source |
| [aws_s3_bucket_object.lambda_zip](https://registry.terraform.io/providers/hashicorp/aws/3.66.0/docs/data-sources/s3_bucket_object) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region to create these resources | `string` | `"ap-southeast-2"` | no |
| <a name="input_cw_event_name"></a> [cw\_event\_name](#input\_cw\_event\_name) | The name for the CloudWatch/EventBridge | `string` | `"lambda-auto-tag-ebs-on-attach"` | no |
| <a name="input_cw_event_schedule"></a> [cw\_event\_schedule](#input\_cw\_event\_schedule) | The cron schedule for the CW event | `string` | `"rate(1 hour)"` | no |
| <a name="input_lambda_cw_logs_retention"></a> [lambda\_cw\_logs\_retention](#input\_lambda\_cw\_logs\_retention) | CloudWatch logs retention in days for the Lambda function | `number` | `7` | no |
| <a name="input_lambda_func_description"></a> [lambda\_func\_description](#input\_lambda\_func\_description) | Description for the Lambda function | `string` | `"Auto tag EBS volume by using attached instance tags"` | no |
| <a name="input_lambda_func_name"></a> [lambda\_func\_name](#input\_lambda\_func\_name) | Name of the Lambda function | `string` | `"auto-tag-ebs-volumes"` | no |
| <a name="input_lambda_iam_policy_name"></a> [lambda\_iam\_policy\_name](#input\_lambda\_iam\_policy\_name) | The name of the IAM policy for the Lambda function | `string` | `"iam_auto_tag_ebs_policy"` | no |
| <a name="input_lambda_iam_role_name"></a> [lambda\_iam\_role\_name](#input\_lambda\_iam\_role\_name) | The name of the IAM role for the Lambda function | `string` | `"iam_auto_tag_ebs_lambda"` | no |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | The name of the S3 bucket that contains the fuction code | `string` | `"lexd-solutions-lambdas"` | no |
| <a name="input_s3_lambda_zip"></a> [s3\_lambda\_zip](#input\_s3\_lambda\_zip) | The object (zip) where the Lambda code is stored | `string` | `"lambda-auto-tag-ebs-volumes.zip"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->