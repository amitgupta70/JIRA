# CloudWatch Alarm
resource "aws_sns_topic" "alarm" {
  name            = "alarms-topic"
  delivery_policy = <<EOF
{
  "http": {
    "defaultHealthyRetryPolicy": {
      "minDelayTarget": 20,
      "maxDelayTarget": 20,
      "numRetries": 3,
      "numMaxDelayRetries": 0,
      "numNoDelayRetries": 0,
      "numMinDelayRetries": 0,
      "backoffFunction": "linear"
    },
    "disableSubscriptionOverrides": false,
    "defaultThrottlePolicy": {
      "maxReceivesPerSecond": 1
    }
  }
}
EOF

 # provisioner "local-exec" {
  #  command = "aws sns subscribe --topic-arn ${self.arn} --protocol email --notification-endpoint ${var.alarms_email}"
  #}
}

# CloudWatch Alarm Metrics - CPU Utilization / Health Check
resource "aws_cloudwatch_metric_alarm" "ec2_cpu" {
  alarm_name                = "cpu-utilization"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120" #seconds
  statistic                 = "Average"
  threshold                 = "80"
  alarm_description         = "This metric monitors ec2 cpu utilization"
  alarm_actions             = [aws_sns_topic.alarm.arn]
  insufficient_data_actions = []
  count                     = 2
  dimensions = {
    InstanceId = element(aws_instance.jira_instances.*.id, count.index)
  }
}

resource "aws_cloudwatch_metric_alarm" "health" {
  alarm_name                = "health-alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "StatusCheckFailed"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "1"
  alarm_description         = "This metric monitors ec2 health status"
  alarm_actions             = [aws_sns_topic.alarm.arn]
  insufficient_data_actions = []
  count                     = 2
  dimensions = {
    InstanceId = element(aws_instance.jira_instances.*.id, count.index)
  }
}
