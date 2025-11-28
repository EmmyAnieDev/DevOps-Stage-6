# HNG13 DevOps Stage6 Task

This repository contains a containerized microservice TODO application with complete Infrastructure as Code (IaC) deployment automation using Terraform and Ansible.

**Live Application:** https://hngtech.name.ng

---

## **NEW TO THIS PROJECT? START HERE!**

**[START_HERE.md](START_HERE.md)** - Your complete deployment guide

⚡ **Quick Deploy:** Run `./setup.sh` (interactive wizard)

**Other Guides:**
- [QUICKSTART.md](QUICKSTART.md) - Minimal 15-minute guide
- [GETTING_STARTED.md](GETTING_STARTED.md) - Detailed step-by-step walkthrough
- [infra/README.md](infra/README.md) - Infrastructure documentation

---

## Overview

A production-ready microservices application with:
- Full containerization with Docker
- HTTPS with automatic SSL certificates (Let's Encrypt)
- Reverse proxy with Traefik
- Infrastructure as Code with Terraform
- Configuration management with Ansible
- CI/CD with drift detection and email alerts
- One-command deployment

## Application Components

1. **[Frontend](/frontend)** - Vue.js UI application
2. **[Auth API](/auth-api)** - Go authentication service with JWT tokens
3. **[Todos API](/todos-api)** - Node.js CRUD API for TODO items
4. **[Users API](/users-api)** - Java Spring Boot user profiles service
5. **[Log Message Processor](/log-message-processor)** - Python Redis queue processor
6. **Redis Queue** - Message broker for async operations

![microservice-app-example](https://user-images.githubusercontent.com/1905821/34918427-a931d84e-f952-11e7-85a0-ace34a2e8edb.png)

## Quick Start

### New to This Project? Start Here!

**Complete step-by-step guide:** See [GETTING_STARTED.md](GETTING_STARTED.md)

**Or use the interactive setup wizard:**
```bash
./setup.sh
```

This wizard will:
- Check prerequisites
- Generate SSH keys
- Configure AWS
- Create S3 bucket
- Deploy infrastructure
- Guide you through each step

### Local Development (Testing Only)

```bash
# Clone the repository
git clone https://github.com/EmmyAnieDev/DevOps-Stage-6.git
cd DevOps-Stage-6

# Start all services
docker-compose up -d

# Access the application
open http://localhost:8080
```

### Production Deployment (Manual)

```bash
# Configure environment
cd infra/terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

# Deploy everything with one command
terraform init
terraform apply -auto-approve
```

This will:
1. Provision AWS EC2 infrastructure
2. Configure networking and security
3. Install Docker and dependencies
4. Deploy the application
5. Configure Traefik with SSL

**Takes 10-15 minutes total**

## Architecture

### Endpoints

- **Frontend:** https://hngtech.name.ng
- **Auth API:** https://hngtech.name.ng/api/auth
- **Todos API:** https://hngtech.name.ng/api/todos
- **Users API:** https://hngtech.name.ng/api/users

### Security Features

- Automatic HTTP → HTTPS redirection
- Let's Encrypt SSL certificates
- Firewall rules (ports 22, 80, 443)
- JWT token authentication
- Docker network isolation

## Infrastructure

### Technology Stack

- **Cloud Provider:** AWS (EC2)
- **IaC:** Terraform 1.6+
- **Configuration:** Ansible 2.15+
- **Containers:** Docker & Docker Compose
- **Reverse Proxy:** Traefik v2
- **CI/CD:** GitHub Actions

### Directory Structure

```
.
├── frontend/                 # Vue.js frontend
├── auth-api/                # Go authentication API
├── todos-api/               # Node.js todos API
├── users-api/               # Java Spring Boot users API
├── log-message-processor/   # Python log processor
├── docker-compose.yml       # Container orchestration
├── .env                     # Environment variables
└── infra/                   # Infrastructure as Code
    ├── terraform/           # Infrastructure provisioning
    └── ansible/             # Configuration management
        └── roles/
            ├── dependencies/  # Install Docker, Git
            └── deploy/        # Deploy application
```

## CI/CD Pipelines

### Infrastructure Workflow

Triggers: Changes to `infra/**` files

1. **Drift Detection:** Runs `terraform plan` to detect changes
2. **Email Alert:** Sends notification if drift detected
3. **Manual Approval:** Waits for approval via GitHub environment
4. **Apply Changes:** Executes `terraform apply` after approval
5. **Auto-Apply:** Proceeds automatically if no drift

### Application Deployment

Triggers: Changes to service code or `docker-compose.yml`

1. Connects to server via SSH
2. Pulls latest changes from repository
3. Rebuilds and restarts containers
4. Verifies deployment health
5. Sends email notification

## Configuration

### Required Secrets (GitHub)

```bash
AWS_ACCESS_KEY_ID         # AWS access key
AWS_SECRET_ACCESS_KEY     # AWS secret key
SSH_PRIVATE_KEY           # SSH key content
SERVER_IP                 # EC2 instance IP address
EMAIL_USERNAME            # SMTP username
EMAIL_PASSWORD            # SMTP password
ALERT_EMAIL              # Notification recipient
```

### Environment Variables

See `.env` file for application configuration:

- Service ports
- JWT secret
- Redis configuration
- API addresses

### Login Credentials

Three test users are available (see `.env`):

| Username | Password   |
|----------|-----------|
| admin    | Admin123  |
| hng      | HngTech   |
| user     | Password  |

## Development

### Adding a New Service

1. Create service directory with Dockerfile
2. Add service to `docker-compose.yml`
3. Configure Traefik labels for routing
4. Update `.env` with required variables

### Testing Locally

```bash
# Build and start services
docker-compose up --build

# View logs
docker-compose logs -f [service-name]

# Stop services
docker-compose down
```

## Monitoring & Troubleshooting

### Check Service Status

```bash
docker-compose ps
```

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f frontend
```

### Connect to Server

```bash
ssh root@<server-ip>
cd /opt/hng-todo-app
```

### Verify SSL Certificates

```bash
curl -vI https://hngtech.name.ng
```

## Features


### Idempotency

- Re-running Terraform with no changes does nothing
- Ansible roles check state before changes
- Containers restart only when needed

### Drift Detection

- Compares actual infrastructure vs. Terraform state
- Email alerts when drift detected
- Manual approval required before applying changes
- Auto-apply when no drift exists

### High Availability

- Automatic container restarts
- Health checks via Traefik
- Graceful deployments

## Documentation

- [Infrastructure Setup](/infra/README.md) - Detailed IaC guide
- [Frontend](/frontend/README.md) - Vue.js application
- [Auth API](/auth-api/README.md) - Authentication service
- [Todos API](/todos-api/README.md) - Todos CRUD API
- [Users API](/users-api/README.md) - User management

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally with `docker-compose up`
5. Submit a pull request

## License

MIT
