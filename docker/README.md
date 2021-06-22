# Docker

## Worker

Simple Python loop that list the databases.

Build docker image

```sh
# Build image
docker build -t bump-worker -f Dockerfile.worker

# Login to ECR repo
aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.eu-central-1.amazonaws.com

# Tag image
docker tag bump-worker:latest  <ACCOUNT_ID>.dkr.ecr.eu-central-1.amazonaws.com/bump-worker:latest

# Push Image
docker push  <ACCOUNT_ID>.dkr.ecr.eu-central-1.amazonaws.com/bump-worker:latest
```

## Web

Simple nginx container with static html page. Code is located in web folder.

Build docker image

```sh
# Build image
docker build -t bump-worker -f Dockerfile.web

# Login to ECR repo
aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.eu-central-1.amazonaws.com

# Tag image
docker tag bump-web:latest  <ACCOUNT_ID>.dkr.ecr.eu-central-1.amazonaws.com/bump-web:latest

# Push Image
docker push  <ACCOUNT_ID>.dkr.ecr.eu-central-1.amazonaws.com/bump-web:latest

```
