# EventBridge rule for EC2 instance state changes
resource "aws_cloudwatch_event_rule" "ec2_changes" {
  name        = "hng-devops-ec2-changes"
  description = "Capture EC2 instance configuration changes"

  event_pattern = jsonencode({
    source      = ["aws.ec2"]
    detail-type = ["EC2 Instance State-change Notification"]
    detail = {
      state = ["running", "stopped", "terminated", "stopping"]
    }
  })

  tags = {
    Name        = "HNG DevOps EC2 Changes"
    Environment = "production"
  }
}

resource "aws_cloudwatch_event_target" "ec2_changes_sns" {
  rule      = aws_cloudwatch_event_rule.ec2_changes.name
  target_id = "SendEC2ChangesToSNS"
  arn       = aws_sns_topic.drift_detection.arn

  input_transformer {
    input_paths = {
      instance   = "$.detail.instance-id"
      state      = "$.detail.state"
      time       = "$.time"
      region     = "$.detail.availability-zone"
    }
    input_template = <<EOF
"EC2 Instance Change Detected\n\nInstance ID: <instance>\nNew State: <state>\nTime: <time>\nRegion: <region>\n\nPlease verify this change matches your Terraform configuration."
EOF
  }
}



# EventBridge rule for scheduled drift detection (every 6 hours)
resource "aws_cloudwatch_event_rule" "scheduled_drift_check" {
  name                = "hng-devops-scheduled-drift-check"
  description         = "Scheduled drift detection check"
  schedule_expression = "rate(6 hours)"

  tags = {
    Name        = "HNG DevOps Scheduled Drift Check"
    Environment = "production"
  }
}

resource "aws_cloudwatch_event_target" "drift_check_sns" {
  rule      = aws_cloudwatch_event_rule.scheduled_drift_check.name
  target_id = "SendDriftCheckToSNS"
  arn       = aws_sns_topic.drift_detection.arn

  input = jsonencode({
    type    = "DriftDetectionCheck"
    message = "Scheduled infrastructure drift detection. Please review your AWS resources and compare with your Terraform configuration."
    action  = "Review infrastructure and run 'terraform plan' to detect any drift"
  })
}

# SNS topic policy to allow EventBridge to publish
resource "aws_sns_topic_policy" "drift_detection_policy" {
  arn = aws_sns_topic.drift_detection.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowEventBridgePublish"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.drift_detection.arn
        Condition = {
          ArnLike = {
            "aws:SourceArn" = "arn:aws:events:*:*:rule/hng-devops-*"
          }
        }
      }
    ]
  })
}
