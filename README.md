# Bump

## Prerequisites

### AWS account

[How to create aws account](https://aws.amazon.com/premiumsupport/knowledge-center/create-and-activate-aws-account/)

### IAM user with Administrative access

[How to create IAM user](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html)

### Terraform

[How to install terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started)

### S3 bucket will be used for the states

[How to create S3 bucket](https://docs.aws.amazon.com/AmazonS3/latest/userguide/create-bucket-overview.html)

Important:
versioning and encryption should be enabled

## Architecture Diagram

![Architecture](architecture.jpeg)

## Resources that will be created

1x S3 bucket

2x ECS Fargate clusters

1x RDS Mysql instance

Cloudwatch alarms

Cloudwatch logs groups

2x ECR reoisitiries

## Initial setup

### Infrastructure as a code

In order to buld the initial infrastructure resources we are using Terraform. Terraform is a tool for building, changing, and versioning infrastructure
safely and efficiently. Terraform can manage existing and popular service providers as well as custom.

Terraform setup uses different states.

In order to proer run the terraform we need fist apply `./terraform/core` folder.

#### Prerequisites

To use this repository and interact with the AWS, you need to do the following:

1. Install and configure Terraform

2. Create an access key for your Santiment AWS account and configure your local AWS profile. You need the following entry in ~/.aws
/credentials :

```sh
[AWS_PROFILE]
aws_access_key_id=XXXX
aws_secret_access_key=XXXX
```

3. To check whether terraform is configured, go to the one of the /terraform/<core, rds, ecs> folders in this repository and execute:

IMPORTANAT: First you need to initaliazie and apply the `core` folder

```sh
terraform init
terraform plan
terraform apply
```

### Buld docker images

## TODO

Setup secretmanager

Setup SOPS for secret encryption

Setup DNS

Setup Certificate Manager

TLS setup for the frontend

## Security

Web and Worker are located in private subnet.

We have separate Database Subnet. Public access is disabled and the traffic to the RDS could only originate from the private netowrk.

Enctrypted database

Encrypted storage (if applicable)

Security groups added to ECS and RDS

Scan Docker images on push

### Security Conciderations

In order to add additional leyer of security all access to the sevices will be trough VPN.

Encryption in transit. All traffic should use TLS/SSL connection. Use encrypted connection to the RDS instance.

Run trough AWS well-architected. This will hepl to identify gaps in the securite best practices.

Configure Cloudflare for DDoS protection.

## DOCKER

[Docker](./docker/README.md)