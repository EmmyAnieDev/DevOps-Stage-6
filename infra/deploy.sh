#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}HNG DevOps Stage 6 - Deployment Script${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

command -v terraform >/dev/null 2>&1 || {
    echo -e "${RED}Error: terraform is not installed${NC}"
    exit 1
}

command -v ansible >/dev/null 2>&1 || {
    echo -e "${RED}Error: ansible is not installed${NC}"
    exit 1
}

echo -e "${GREEN}✓ Prerequisites check passed${NC}"
echo ""

# Check if terraform.tfvars exists
if [ ! -f "terraform/terraform.tfvars" ]; then
    echo -e "${YELLOW}terraform.tfvars not found. Creating from example...${NC}"
    cp terraform/terraform.tfvars.example terraform/terraform.tfvars
    echo -e "${RED}Please edit terraform/terraform.tfvars with your values before continuing${NC}"
    exit 1
fi

# Navigate to terraform directory
cd terraform

# Initialize Terraform
echo -e "${YELLOW}Initializing Terraform...${NC}"
terraform init

# Plan
echo -e "${YELLOW}Running Terraform plan...${NC}"
terraform plan -out=tfplan

# Ask for confirmation
echo ""
read -p "Do you want to apply these changes? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo -e "${RED}Deployment cancelled${NC}"
    exit 0
fi

# Apply
echo -e "${YELLOW}Applying Terraform changes...${NC}"
terraform apply tfplan

# Get outputs
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Deployment Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

INSTANCE_IP=$(terraform output -raw instance_ip 2>/dev/null || echo "N/A")
APP_URL=$(terraform output -raw app_url 2>/dev/null || echo "N/A")

echo -e "${GREEN}Server IP:${NC} $INSTANCE_IP"
echo -e "${GREEN}Application URL:${NC} $APP_URL"
echo ""
echo -e "${YELLOW}Note: SSL certificates may take 5-10 minutes to provision${NC}"
echo -e "${YELLOW}Update your domain DNS to point to: $INSTANCE_IP${NC}"
echo -e "${YELLOW}Check logs: ssh ubuntu@$INSTANCE_IP 'cd /opt/hng-todo-app && docker-compose logs -f'${NC}"
echo ""
