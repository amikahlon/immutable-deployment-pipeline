#!/bin/bash
set -euo pipefail

yum update -y
yum install -y docker
systemctl enable --now docker
usermod -aG docker ec2-user

# התחברות ל-ECR
aws ecr get-login-password --region ${region} \
  | docker login --username AWS --password-stdin ${ecr_registry}

docker pull ${client_image}

docker run -d \
  --name client \
  --restart unless-stopped \
  -p 3000:3000 \
  ${client_image}
