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

# Development Notes
## Build and push container image to ECR
Use the following to build image and push to AWS ECR
```
$ docker build . -t 682613435495.dkr.ecr.ap-southeast-2.amazonaws.com/jumpbox_uptime:latest

# Note: Must be us-east-1, otherwise it won't work.
$ aws ecr get-login-password --region ap-southeast-2 | docker login --username AWS --password-stdin 682613435495.dkr.ecr.ap-southeast-2.amazonaws.com

$ docker push 682613435495.dkr.ecr.ap-southeast-2.amazonaws.com/jumpbox_uptime:latest

# Image URI will be: 682613435495.dkr.ecr.ap-southeast-2.amazonaws.com/jumpbox_uptime:latest
```


## Testing locally
As I am  using a container image on ECR, this is how I can test the Lambda function locally via docker.

```
# note:  192.168.0.5 is my local VM that is running Docker
$ docker build . -t lambdalocaltest
$ docker run -p 9000:8080 --rm lambdalocaltest

$ curl -XPOST "http://192.168.0.5:9000/2015-03-31/functions/function/invocations" -d '{"name": "alex"}'
```

After hitting the endpoint via curl, I can see the STDOUT on docker.
Example:
```
$ docker run -p 9000:8080 --rm lambdalocaltest
18 Jan 2022 03:45:38,236 [INFO] (rapid) exec '/var/runtime/bootstrap' (cwd=/var/task, handler=)
START RequestId: 58288cf1-4d7f-41cd-bd45-7af545867f75 Version: $LATEST
Hello AWS!
event = {'name': 'alex'}
END RequestId: 58288cf1-4d7f-41cd-bd45-7af545867f75
REPORT RequestId: 58288cf1-4d7f-41cd-bd45-7af545867f75  Duration: 0.75 ms       Billed Duration: 1 ms   Memory Size: 3008 MB    Max Memory Used: 3008 MB
```