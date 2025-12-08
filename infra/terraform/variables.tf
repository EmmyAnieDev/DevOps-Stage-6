variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "instance_name" {
  description = "Name of the EC2 instance"
  type        = string
  default     = "hng-todo-app"
}

variable "domain" {
  description = "Domain name for the application"
  type        = string
  default     = "hngtech.name.ng"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "ssh_private_key_path" {
  description = "Path to SSH private key"
  type        = string
  default     = "~/.ssh/id_rsa"
}

variable "notification_email" {
  description = "Email address for drift detection and infrastructure change notifications"
  type        = string
  sensitive   = true
}

