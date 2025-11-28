output "instance_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_eip.app_eip.public_ip
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.app_server.id
}

output "domain" {
  description = "Domain name"
  value       = var.domain
}

output "app_url" {
  description = "Application URL"
  value       = "https://${var.domain}"
}
