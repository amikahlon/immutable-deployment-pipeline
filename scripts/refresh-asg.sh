#!/usr/bin/env bash
set -euo pipefail

AWS_REGION="$1"
PROJECT_NAME="$2"
ECR_REGISTRY="$3"
CLIENT_IMAGE="$4"
SERVER_IMAGE="$5"

# ── פונקציה: מוצאת Launch Template ID לפי pattern ───────────────────────────
get_lt_id() {
  local pattern="$1"
  local lt_id

  lt_id=$(aws ec2 describe-launch-templates \
    --region "$AWS_REGION" \
    --filters "Name=launch-template-name,Values=${pattern}" \
    --query "LaunchTemplates[0].LaunchTemplateId" \
    --output text)

  if [[ "$lt_id" == "None" || -z "$lt_id" ]]; then
    echo "ERROR: Launch Template לא נמצא עבור pattern: ${pattern}" >&2
    exit 1
  fi

  echo "$lt_id"
}

# ── פונקציה: יוצרת גרסת LT חדשה עם user_data מעודכן ────────────────────────
create_lt_version() {
  local lt_id="$1"
  local user_data_b64="$2"

  aws ec2 create-launch-template-version \
    --region "$AWS_REGION" \
    --launch-template-id "$lt_id" \
    --source-version '$Latest' \
    --launch-template-data "{\"UserData\": \"${user_data_b64}\"}" \
    --query "LaunchTemplateVersion.VersionNumber" \
    --output text
}

# ── פונקציה: מפעילה Instance Refresh על ASG ─────────────────────────────────
start_refresh() {
  local asg_name="$1"

  aws autoscaling start-instance-refresh \
    --region "$AWS_REGION" \
    --auto-scaling-group-name "$asg_name" \
    --strategy Rolling \
    --preferences '{"MinHealthyPercentage": 50, "InstanceWarmup": 120}' \
    --query "InstanceRefreshId" \
    --output text
}

# ============================================================
# CLIENT
# ============================================================
echo "── Client ──────────────────────────────────────────"

CLIENT_LT_ID=$(get_lt_id "${PROJECT_NAME}-lt-client-*")
echo "Launch Template: $CLIENT_LT_ID"

CLIENT_USER_DATA=$(base64 -w0 << EOF
#!/bin/bash
set -euo pipefail
yum update -y
yum install -y docker
systemctl enable --now docker
usermod -aG docker ec2-user
aws ecr get-login-password --region $AWS_REGION \
  | docker login --username AWS --password-stdin $ECR_REGISTRY
docker pull $CLIENT_IMAGE
docker run -d \
  --name client \
  --restart unless-stopped \
  -p 3000:3000 \
  $CLIENT_IMAGE
EOF
)

CLIENT_VERSION=$(create_lt_version "$CLIENT_LT_ID" "$CLIENT_USER_DATA")
echo "גרסה חדשה: $CLIENT_VERSION"

CLIENT_REFRESH=$(start_refresh "${PROJECT_NAME}-client-asg")
echo "Instance Refresh: $CLIENT_REFRESH"

# ============================================================
# SERVER
# ============================================================
echo "── Server ──────────────────────────────────────────"

SERVER_LT_ID=$(get_lt_id "${PROJECT_NAME}-lt-server-*")
echo "Launch Template: $SERVER_LT_ID"

SERVER_USER_DATA=$(base64 -w0 << EOF
#!/bin/bash
set -euo pipefail
yum update -y
yum install -y docker
systemctl enable --now docker
usermod -aG docker ec2-user
aws ecr get-login-password --region $AWS_REGION \
  | docker login --username AWS --password-stdin $ECR_REGISTRY
docker pull $SERVER_IMAGE
docker run -d \
  --name server \
  --restart unless-stopped \
  -p 4000:4000 \
  $SERVER_IMAGE
EOF
)

SERVER_VERSION=$(create_lt_version "$SERVER_LT_ID" "$SERVER_USER_DATA")
echo "גרסה חדשה: $SERVER_VERSION"

SERVER_REFRESH=$(start_refresh "${PROJECT_NAME}-server-asg")
echo "Instance Refresh: $SERVER_REFRESH"

echo "── Deploy הושק בהצלחה ──────────────────────────────"
