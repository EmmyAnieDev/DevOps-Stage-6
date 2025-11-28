# Infrastructure Setup - HNG DevOps Stage 6

This directory contains Infrastructure as Code (IaC) for deploying the HNG TODO microservices application on AWS.

## Prerequisites

- Terraform >= 1.0
- Ansible >= 2.15
- AWS account with credentials configured
- SSH key pair
- Domain configured (hngtech.name.ng)

## Directory Structure

```
infra/
├── terraform/
│   ├── main.tf                 # Main infrastructure configuration
│   ├── variables.tf            # Input variables
│   ├── outputs.tf              # Output values
│   ├── backend.tf              # Remote state configuration
│   └── ansible-inventory.tpl   # Ansible inventory template
└── ansible/
    ├── playbook.yml            # Main playbook
    └── roles/
        ├── dependencies/       # Install Docker, Git, etc.
        └── deploy/             # Deploy application
```

## Setup Instructions

### 1. Configure Backend Storage

Create S3 bucket for Terraform state:

```bash
# Create S3 bucket
aws s3 mb s3://hng-devops-terraform-state --region us-east-1

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket hng-devops-terraform-state \
  --versioning-configuration Status=Enabled

# Enable encryption
aws s3api put-bucket-encryption \
  --bucket hng-devops-terraform-state \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'
```

### 2. Configure AWS Credentials

```bash
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key
# Default region: us-east-1
```

### 3. Generate SSH Keys

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa
```

### 4. Configure Variables

```bash
cd infra/terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

### 5. Deploy Infrastructure

```bash
cd infra/terraform
terraform init
terraform plan
terraform apply
```

This will:
- Provision an AWS EC2 instance
- Configure security groups
- Allocate an Elastic IP
- Generate Ansible inventory
- Run Ansible playbook to:
  - Install Docker and dependencies
  - Clone the application repository
  - Deploy services with docker-compose
  - Configure Traefik with SSL

## CI/CD Workflows

### Infrastructure Workflow

Triggers on changes to `infra/**` files:

1. Runs `terraform plan`
2. Detects drift
3. Sends email alert if drift exists
4. Waits for manual approval (production environment)
5. Applies changes after approval
6. Auto-applies if no drift detected

### Application Deployment Workflow

Triggers on changes to application code:

1. Connects to server via SSH
2. Pulls latest code
3. Rebuilds and restarts containers
4. Verifies deployment
5. Sends notification email

## Required GitHub Secrets

Configure these in GitHub repository settings:

- `AWS_ACCESS_KEY_ID` - AWS access key
- `AWS_SECRET_ACCESS_KEY` - AWS secret key
- `SSH_PRIVATE_KEY` - SSH private key content
- `SERVER_IP` - EC2 instance IP address
- `EMAIL_USERNAME` - SMTP username (Gmail)
- `EMAIL_PASSWORD` - SMTP password/app password
- `ALERT_EMAIL` - Email for notifications

## Drift Detection

The pipeline automatically detects infrastructure drift by comparing:
- Current state in Terraform state file
- Actual infrastructure in AWS

When drift is detected:
1. Email alert sent to configured address
2. Pipeline pauses for manual approval
3. Changes applied only after approval

## Idempotency

All infrastructure code is idempotent:
- Re-running `terraform apply` with no changes does nothing
- Ansible roles check state before making changes
- Docker containers restart only if code changed

## Manual Deployment

To deploy manually:

```bash
# From project root
cd infra/terraform
terraform apply -auto-approve
```

This single command:
1. Provisions infrastructure
2. Generates Ansible inventory
3. Runs Ansible playbook
4. Deploys application

## Troubleshooting

### Terraform State Lock

State locking is not enabled by default. If you need state locking, add a DynamoDB table.

### Ansible Connection Issues

Test SSH connection:
```bash
ssh -i ~/.ssh/id_rsa ubuntu@<server-ip>
```

### Check Application Logs

```bash
ssh ubuntu@<server-ip>
cd /opt/hng-todo-app
docker-compose logs -f
```

## Cleanup

To destroy all infrastructure:

```bash
cd infra/terraform
terraform destroy
```

⚠️ This will delete the EC2 instance and all data!
