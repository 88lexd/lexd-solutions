# Notify When Jumpbox Uptime Exceeded Threshold
Background: In my new design, I have a dedicated EC2 jumpbox instance running on AWS for me to manage my servers.

To learn more about it, see my blog post here: https://lexdsolutions.com/2022/01/replacing-microk8s-with-kubernetes-cluster-created-by-kubeadm/

## Why I created this
As I don't always access my EC2 jumpbox, having it running 24/7 is a waste of money. So each time I need to manage my cluster, I use another script which I've written to power-on the instance and then power it off when I am done with it.

If you want to know more about this script, you can find it here: https://github.com/88lexd/lexd-solutions/tree/main/misc-scripts/python-aws-jumpbox

The problem I have with this is if I ever forget to run the stop command, my instance will remain in a running state and time = money.

## My Options
I could use the CloudWatch agent to push the instance uptime to CloudWatch and create an alarm if the uptime is greater than my threshold then send out a notification, however this doesn't seem like any fun and I can't apply this easily using IaC (Infrastructure as Code).

This is why I decided to go with a Lambda function instead and have this being created through Terraform.

## How it works
CloudWatch will trigger my Lambda function every hour and will do the following:
 - If the jumpbox instance is running for more than the "NOTIFICATION_THRESHOLD", then send out a notification via SNS.
 - If the jumpbox instance is running for more than the "UPTIME_THRESHOLD", then **stop** the instance and send out a notification via SNS.
