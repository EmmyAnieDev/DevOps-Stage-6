# Complete Setup Guide

This guide walks you through setting up the entire infrastructure from scratch.

## Step 1: Prerequisites

### Install Required Tools

```bash
# Terraform
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# Ansible
pip install ansible==2.15.0

# AWS CLI
pip install awscli
```

### Create AWS Account

1. Go to https://aws.amazon.com
2. Create an account
3. Set up billing alerts

## Step 2: Generate SSH Keys

```bash
# Generate SSH key pair
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa
```

## Step 3: Configure AWS Backend

### Configure AWS Credentials

```bash
# Configure AWS credentials
aws configure
# Enter AWS Access Key ID
# Enter AWS Secret Access Key
# Default region: us-east-1
# Default output format: json
```

### Create S3 Bucket for State

```bash
# Create S3 bucket for Terraform state
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

## Step 4: Configure Domain

Update your domain's DNS settings to point to the EC2 Elastic IP (you'll get this after deployment).

## Step 5: Configure GitHub

### Fork and Clone Repository

```bash
# Fork the repository on GitHub
# Then clone your fork
git clone https://github.com/YOUR_USERNAME/DevOps-Stage-6.git
cd DevOps-Stage-6
```

### Set Up GitHub Secrets

Go to: Settings → Secrets and variables → Actions → New repository secret

Add these secrets:

```bash
AWS_ACCESS_KEY_ID       # Your AWS access key
AWS_SECRET_ACCESS_KEY   # Your AWS secret key
SSH_PRIVATE_KEY         # Contents of ~/.ssh/id_rsa
EMAIL_USERNAME          # Your Gmail address
EMAIL_PASSWORD          # Gmail app password
ALERT_EMAIL            # Email to receive alerts
```

### Create Gmail App Password

1. Go to https://myaccount.google.com/security
2. Enable 2-Factor Authentication
3. Go to App Passwords
4. Create password for "Mail"
5. Copy the 16-character password
6. Use this as `EMAIL_PASSWORD` secret

### Create GitHub Environment

1. Go to: Settings → Environments
2. Click "New environment"
3. Name: "production"
4. Check "Required reviewers"
5. Add yourself as a reviewer
6. Save

This enables manual approval for infrastructure changes.

## Step 6: Configure Terraform

```bash
cd infra/terraform

# Copy example variables
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
nano terraform.tfvars
```

Set these values in `terraform.tfvars`:

```hcl
aws_region          = "us-east-1"
instance_type       = "t3.medium"
instance_name       = "hng-todo-app"
ssh_public_key_path = "~/.ssh/id_rsa.pub"
ssh_private_key_path = "~/.ssh/id_rsa"
domain              = "hngtech.name.ng"
```

## Step 7: Update Ansible Configuration

Edit `infra/ansible/group_vars/all.yml`:

```yaml
github_username: "YOUR_GITHUB_USERNAME"
github_repo: "DevOps-Stage-6"
github_branch: "main"
```

## Step 8: Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Deploy everything
terraform apply -auto-approve
```

This will:
- Create EC2 instance
- Allocate Elastic IP
- Configure security group
- Install Docker and dependencies
- Deploy the application
- Configure SSL with Let's Encrypt

Wait 5-10 minutes for:
- Instance initialization
- SSL certificate generation
- Application startup

## Step 9: Update DNS

After deployment, get the Elastic IP:

```bash
terraform output instance_ip
```

Update your domain DNS:
1. Go to your domain provider
2. Add/update A record for `hngtech` pointing to the Elastic IP

## Step 10: Update GitHub Secrets

After first deployment:

```bash
# Get the instance IP
cd infra/terraform
terraform output instance_ip
```

Add this as `SERVER_IP` secret in GitHub.

## Step 11: Verify Deployment

### Check Application

```bash
# Wait for DNS propagation (can take a few minutes)
curl -I http://hngtech.name.ng

# Test HTTPS (after SSL cert is ready)
curl -I https://hngtech.name.ng
```

### Check Services

```bash
# SSH to server
ssh -i ~/.ssh/id_rsa ubuntu@$(terraform output -raw instance_ip)

# Check containers
docker-compose ps

# Check logs
docker-compose logs -f

# Exit SSH
exit
```

## Step 12: Test CI/CD

### Test Infrastructure Pipeline

```bash
# Make a change to Terraform
cd infra/terraform
echo "# test" >> outputs.tf

# Commit and push
git add .
git commit -m "Test infrastructure pipeline"
git push origin main
```

You should:
1. Receive drift detection email (if changes detected)
2. See workflow waiting for approval in GitHub Actions
3. Approve in GitHub → Actions → Review deployments
4. Receive deployment success email

### Test Application Pipeline

```bash
# Make a change to application
cd frontend
echo "// test" >> package.json

# Commit and push
git add .
git commit -m "Test deployment pipeline"
git push origin main
```

You should:
1. See workflow running in GitHub Actions
2. Receive deployment notification email

## Step 13: Access Application

1. Open browser to https://hngtech.name.ng
2. You should see the login page
3. Login with credentials from `.env`:
   - Username: `admin`, Password: `Admin123`
   - Username: `hng`, Password: `HngTech`
   - Username: `user`, Password: `Password`

## Troubleshooting

### SSL Certificate Not Working

Wait 5 minutes for Let's Encrypt validation. Check logs:

```bash
ssh ubuntu@<server-ip>
docker-compose logs traefik
```

### Services Not Starting

Check container logs:

```bash
ssh ubuntu@<server-ip>
docker-compose ps
docker-compose logs -f
```

### DNS Not Resolving

DNS propagation can take time. Check:

```bash
dig hngtech.name.ng @8.8.8.8
```

### Email Alerts Not Sending

Verify Gmail app password and secrets are correct.

## Cleanup

To destroy all infrastructure:

```bash
cd infra/terraform
terraform destroy
```

⚠️ This deletes everything! Only do this if you're sure.

## Summary

You now have:
- ✅ AWS EC2 instance running Ubuntu
- ✅ All services containerized with Docker
- ✅ Traefik reverse proxy with SSL
- ✅ Infrastructure as Code with Terraform
- ✅ Configuration management with Ansible
- ✅ CI/CD pipelines with drift detection
- ✅ Email notifications
- ✅ Single-command deployment
