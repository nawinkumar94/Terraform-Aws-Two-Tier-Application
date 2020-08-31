### Autoscaling policy ###
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = var.auto_scale_grp
  policy_type            = "SimpleScaling"
}

### cloud watch Alarm ###
resource "aws_cloudwatch_metric_alarm" "scale_up_alarm" {
  alarm_name                = "scale-up-alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "30"
  dimensions = {
    AutoScalingGroupName = var.auto_scale_grp
  }

  alarm_description = "This metric monitors ec2 when cpu utilization goes up"
  alarm_actions     = [aws_autoscaling_policy.scale_up.arn]
}

### Autoscaling policy ###
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = var.auto_scale_grp
  policy_type            = "SimpleScaling"
}

### cloud watch Alarm ###
resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
  alarm_name                = "scale-down-alarm"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "5"
  dimensions = {
    AutoScalingGroupName = var.auto_scale_grp
  }

  alarm_description = "This metric monitors ec2 when cpu utilization goes down"
  alarm_actions     = [aws_autoscaling_policy.scale_up.arn]
}


resource "aws_sns_topic" "inventory-sns" {
  name         = "sg-sns"
  display_name = "inventory ASG SNS topic"
}

resource "aws_autoscaling_notification" "inventory-notify" {
  group_names = [var.auto_scale_grp]
  topic_arn     = "${aws_sns_topic.inventory-sns.arn}"
  notifications  = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR"
  ]
}
