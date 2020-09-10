output "auto_scale_grp"{
  value = aws_autoscaling_group.auto_scale_grp.name
  description = "Name of the autoscaling group"
}
