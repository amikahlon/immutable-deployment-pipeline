#!/bin/bash
set -euo pipefail

yum update -y
yum install -y docker
systemctl enable --now docker
usermod -aG docker ec2-user

# התחברות ל-ECR
aws ecr get-login-password --region ${region} \
  | docker login --username AWS --password-stdin ${ecr_registry}

docker pull ${server_image}

docker run -d \
  --name server \
  --restart unless-stopped \
  -p 4000:4000 \
  ${server_image}
