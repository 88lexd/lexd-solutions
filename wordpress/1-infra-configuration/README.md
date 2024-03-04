# Infrastructure Configuration
**Base setup** is using Cloud Formation to configure the bare minimum resources such as the first IAM user, IAM roles, IAM policies and S3 bucket and Dynamo DB


**General Setup** uses Terraform to create all the remaining resources to support the WordPress application running under Kubernetes.

For more information, check out my blog post here: https://lexdsolutions.com/2021/09/using-cloudformation-and-terraform-on-my-brand-new-aws-account/