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

## Testing Locally
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
    "sourceIPAddress": "49.195.113.66",
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
