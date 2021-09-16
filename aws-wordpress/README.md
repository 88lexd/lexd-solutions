# My AWS Wordpress Site
This directory contains all the code used to build out my personal WordPress site (https://lexdsolutions.com).

From day 1, everything is built using IaC (infrastructure as code). The following tooling is used:

 - Amazon Web Service (AWS)
 - EC2 (Ubuntu)
 - S3 and DynamoDB for Terraform state and locking
 - Kubernetes (MicroK8s)
 - CloudFormation (base-setup)
 - Terraform (provision infrastructure to support the application)
 - Ansible (configure the OS and setup MicroK8s)
 - LetsEncrypt (TLS certificate for Ingress)

 ## Design Decisions
The initial design is to keep this at the lowest cost possible. Once traffic picks up then the next phase will be to scale out.

Reason to use MicroK8s is so I can be more of a consumer of Kubernetes and not so much on the administration side to begin with.

More details about the design decisions and the future phases of this project will be oulined in my future blogs.

# Folder Structure
## 1-infra-configuration
Contains the code for configuring the AWS infrastructure. Tools include:
 - AWS CloudFormation
 - Terraform

## 2-os-configuration
Contains the code for configuring the EC2 instances with Microk8s and other custom settings on the OS. Tools include:

 - Ansible

## 3-app-configuration
Contains the Helm chart for installing and spinning up resources on Kubernetes for the WordPress site. Tools include:
 - Kubernetes Helm Chart
