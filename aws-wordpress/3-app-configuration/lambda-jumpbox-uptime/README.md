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
