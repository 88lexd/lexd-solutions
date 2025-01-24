# Important Update!
As of December 2024, I have fully migrated off WordPress and my blog now runs on Astro.

Most of the code here in this directory is now archived with only a few things that are still being used.

The new repo that hosts my new blog is located at: https://github.com/88lexd/website-astro

As I get time, I will be slowly moving my code over to the new repo. This repo will contain generic code such as what I currently have in `misc-scripts`.

# My AWS Wordpress Site
This directory contains all the code used to build out my personal WordPress site (https://lexdsolutions.com).

From day 1, everything is built using IaC (infrastructure as code). The following tooling is used:

 - Amazon Web Service (AWS)
 - EC2 (Ubuntu)
 - S3 and DynamoDB for Terraform state and locking
 - Kubernetes
 - CloudFormation (base-setup)
 - Terraform (provision infrastructure to support the application)
 - Ansible (configure the OS and setup Kubernetes)
 - LetsEncrypt (TLS certificate for Ingress)

**IMPORTANT UPDATE:** As of early 2024 I have migrated my website from AWS to be self hosted.

# Folder Structure
## 1-infra-configuration
Contains the code for configuring my local infrastructure. Tools used include:
 - AWS CloudFormation
 - Terraform
 - Ansible

## 2-os-configuration
Contains the code for configuring the EC2 instances with Kubernetes and other custom settings on the OS. Tools used include:
 - Ansible

## 3-app-configuration
Contains the Helm chart for installing and spinning up resources on Kubernetes for the WordPress site. Tools used include:
 - Kubernetes Helm Chart
