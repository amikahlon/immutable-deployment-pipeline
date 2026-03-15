# Immutable Deployment Pipeline

פרויקט זה מדגים pipeline לפריסה אוטומטית של אפליקציה (Client + Server) ל-AWS.
כל push ל-`main` בונה Docker images חדשים, דוחף ל-ECR, ומחליף את ה-EC2 instances בצורה rolling ללא downtime.

---

## ארכיטקטורה

```
Internet → ALB → /        → client-asg → 2x EC2 (Next.js :3000)
                → /api/*  → server-asg → 2x EC2 (Express  :4000)

כל EC2 מושב ב-Private Subnet ומושך images מ-ECR דרך NAT Gateway.
GitHub Actions מזדהה ל-AWS באמצעות OIDC — ללא access keys.
```

---

## דרישות מקדימות

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.5.0
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) מוגדר עם credentials
- חשבון AWS עם הרשאות מספיקות (Admin או PowerUser)
- Git repository ב-GitHub

---

## הרצה ראשונה

### 1. הגדר AWS credentials מקומיים

```bash
aws configure
```

```
AWS Access Key ID:     <המפתח שלך>
AWS Secret Access Key: <הסוד שלך>
Default region name:   eu-central-1
Default output format: json
```

בדוק שעובד:

```bash
aws sts get-caller-identity
```

---

### 2. עדכן את `infra/terraform.tfvars`

```hcl
github_org  = "שם-המשתמש-שלך-בגיטהאב"
github_repo = "שם-הרפוזיטורי"
```

שאר הערכים אפשר להשאיר כמו שהם.

---

### 3. הרץ Terraform

```bash
cd infra
terraform init
terraform apply
```

כשישאל — הקלד `yes`.

בסוף ה-apply יופיעו outputs, לדוגמה:

```
alb_dns_name            = "system-info-app-alb-xxxxxxxxxx.eu-central-1.elb.amazonaws.com"
client_ecr_url          = "123456789.dkr.ecr.eu-central-1.amazonaws.com/system-info-app-client"
server_ecr_url          = "123456789.dkr.ecr.eu-central-1.amazonaws.com/system-info-app-server"
github_actions_role_arn = "arn:aws:iam::123456789:role/system-info-app-github-actions"
client_asg_name         = "system-info-app-client-asg"
server_asg_name         = "system-info-app-server-asg"
```

תעתיק את `github_actions_role_arn` — תצטרך אותו בצעד הבא.
אפשר לקבל אותו שוב בכל עת עם:

```bash
terraform output github_actions_role_arn
```

---

### 4. הגדר GitHub Actions Variable

כנס ל-repository שלך ב-GitHub:
**Settings → Secrets and variables → Actions → Variables → New repository variable**

| Name | Value |
|------|-------|
| `AWS_ROLE_ARN` | ה-ARN שקיבלת בצעד הקודם |

---

### 5. Push והמתן

```bash
git add .
git commit -m "initial deploy"
git push origin main
```

כנס ל-**Actions** ב-GitHub ועקוב אחרי ה-run.
בסיום — האפליקציה זמינה בכתובת ה-`alb_dns_name` שקיבלת.

---

## כיצד עובד ה-Deploy האוטומטי

בכל push ל-`main` ה-workflow מבצע:

1. מזדהה ל-AWS דרך OIDC (ללא secrets)
2. בונה Docker image לשרת → דוחף ל-ECR עם tag של commit SHA
3. קורא את ה-ALB DNS מ-SSM → בונה Docker image לקליינט → דוחף ל-ECR
4. יוצר גרסת Launch Template חדשה לכל ASG עם ה-image החדש
5. מפעיל Instance Refresh — מחליף EC2 instances בהדרגה ללא downtime

---

## מבנה הפרויקט

```
.
├── client/                  # Next.js frontend
├── server/                  # Express backend
├── infra/
│   ├── main.tf              # חיבור בין המודולים
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars     # ← כאן מגדירים github_org + github_repo
│   └── modules/
│       ├── network/         # VPC, Subnets, ALB Security Groups
│       ├── ecr/             # ECR repositories
│       ├── alb/             # ALB, Target Groups, Listener Rules
│       ├── compute/         # Launch Templates, ASGs, IAM Role ל-EC2
│       └── github-oidc/     # OIDC Provider + IAM Role ל-GitHub Actions
├── scripts/
│   └── refresh-asg.sh       # מעדכן Launch Template ומפעיל Instance Refresh
└── .github/
    └── workflows/
        └── deploy.yml       # GitHub Actions pipeline
```

---

## Rollback

כדי לחזור לגרסה קודמת — בצע revert ל-commit הרצוי ו-push:

```bash
git revert HEAD
git push origin main
```

ה-pipeline ירוץ שוב ויפרוס את הגרסה הקודמת.
