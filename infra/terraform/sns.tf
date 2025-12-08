resource "aws_sns_topic" "drift_detection" {
  name = "hng-devops-drift-detection"

  tags = {
    Name        = "HNG DevOps Drift Detection"
    Environment = "production"
  }
}

resource "aws_sns_topic_subscription" "drift_detection_email" {
  topic_arn = aws_sns_topic.drift_detection.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for drift detection"
  value       = aws_sns_topic.drift_detection.arn
}

output "sns_topic_name" {
  description = "Name of the SNS topic"
  value       = aws_sns_topic.drift_detection.name
}
