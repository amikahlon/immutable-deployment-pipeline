# Immutable Deployment Pipeline

A CI/CD pipeline that deploys a Next.js frontend and Express backend to AWS.
Every push to `main` builds new Docker images, pushes them to ECR, and replaces the EC2 instances with zero downtime.

---

## How it works

```
Internet → ALB → /       → client-asg → 2x EC2 (Next.js :3000)
               → /api/*  → server-asg → 2x EC2 (Express  :4000)
```

- EC2 instances run in private subnets and pull images from ECR through a NAT Gateway
- GitHub Actions authenticates to AWS using OIDC — no access keys stored anywhere
- Each deploy creates a new Launch Template version and triggers a rolling Instance Refresh

---

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.5.0
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) configured with your credentials
- An AWS account with Admin or PowerUser permissions
- A GitHub repository

---

## Setup

### 1. Configure AWS credentials locally

```bash
aws configure
```

```
AWS Access Key ID:     <your key>
AWS Secret Access Key: <your secret>
Default region name:   eu-central-1
Default output format: json
```

Verify it works:

```bash
aws sts get-caller-identity
```

---

### 2. Update `infra/terraform.tfvars`

```hcl
github_org  = "your-github-username"
github_repo = "your-repository-name"
```

Everything else can stay as is.

---

### 3. Run Terraform

```bash
cd infra
terraform init
terraform apply
```

Type `yes` when prompted.

At the end you'll see outputs like:

```
alb_dns_name            = "system-info-app-alb-xxxxxxxxxx.eu-central-1.elb.amazonaws.com"
client_ecr_url          = "123456789.dkr.ecr.eu-central-1.amazonaws.com/system-info-app-client"
server_ecr_url          = "123456789.dkr.ecr.eu-central-1.amazonaws.com/system-info-app-server"
github_actions_role_arn = "arn:aws:iam::123456789:role/system-info-app-github-actions"
```

Copy the `github_actions_role_arn` value — you'll need it in the next step.
You can always get it again with:

```bash
terraform output github_actions_role_arn
```

---

### 4. Add a GitHub Actions variable

Go to your repository on GitHub:
**Settings → Secrets and variables → Actions → Variables → New repository variable**

| Name           | Value                          |
| -------------- | ------------------------------ |
| `AWS_ROLE_ARN` | the ARN from the previous step |

---

### 5. Push and watch it deploy

```bash
git add .
git commit -m "initial deploy"
git push origin main
```

Go to the **Actions** tab on GitHub to follow the run.
Once it's done, the app is live at the `alb_dns_name` from step 3.

---

## Project structure

```
.
├── client/                  # Next.js frontend
├── server/                  # Express backend
├── infra/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars     # ← set github_org and github_repo here
│   └── modules/
│       ├── network/         # VPC, subnets, security groups
│       ├── ecr/             # ECR repositories
│       ├── alb/             # ALB, target groups, listener rules
│       ├── compute/         # Launch templates, ASGs, EC2 IAM role
│       └── github-oidc/     # OIDC provider and IAM role for GitHub Actions
├── scripts/
│   └── refresh-asg.sh       # updates the launch template and triggers instance refresh
└── .github/
    └── workflows/
        └── deploy.yml       # CI/CD pipeline
```

---

## Rollback

Revert the commit you want to undo and push:

```bash
git revert HEAD
git push origin main
```

The pipeline will run again and deploy the previous version.
