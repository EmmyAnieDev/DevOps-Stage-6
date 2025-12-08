provider "aws" {
  region = var.aws_region
}

# Get latest Ubuntu 22.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Create SSH key pair
resource "aws_key_pair" "deployer" {
  key_name   = "${var.instance_name}-key"
  public_key = file(var.ssh_public_key_path)
}

# Security group
resource "aws_security_group" "app_sg" {
  name        = "${var.instance_name}-sg"
  description = "Security group for HNG TODO app"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "${var.instance_name}-sg"
    ManagedBy = "terraform"
    Project   = "HNG-DevOps-Emmy-6"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# EC2 instance
resource "aws_instance" "app_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  root_block_device {
    volume_size = 20
    volume_type = "gp2"
  }

  tags = {
    Name        = var.instance_name
    Environment = "production"
    ManagedBy   = "terraform"
    Project     = "HNG-DevOps"
    Owner       = "DevOps-Team"
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [ami, root_block_device]
  }
}

# Elastic IP
resource "aws_eip" "app_eip" {
  instance = aws_instance.app_server.id
  domain   = "vpc"

  tags = {
    Name = "${var.instance_name}-eip"
  }

  depends_on = [aws_instance.app_server]
}

# Generate Ansible inventory
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/ansible-inventory.tpl", {
    server_ip            = aws_eip.app_eip.public_ip
    ssh_private_key_path = var.ssh_private_key_path
  })
  filename = "${path.module}/../ansible/inventory.ini"

  depends_on = [aws_eip.app_eip]
}

# Wait for instance to be ready
resource "null_resource" "wait_for_instance" {
  depends_on = [aws_eip.app_eip]

  provisioner "remote-exec" {
    inline = ["echo 'Instance is ready'"]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
      host        = aws_eip.app_eip.public_ip
      timeout     = "5m"
    }
  }
}

# Run Ansible playbook
resource "null_resource" "run_ansible" {
  depends_on = [local_file.ansible_inventory, null_resource.wait_for_instance]

  triggers = {
    instance_id = aws_instance.app_server.id
  }

  provisioner "local-exec" {
    command     = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${path.module}/../ansible/inventory.ini ${path.module}/../ansible/playbook.yml"
    working_dir = path.module
    environment = {
      ANSIBLE_CONFIG = "${path.module}/../ansible/ansible.cfg"
    }
  }
}
