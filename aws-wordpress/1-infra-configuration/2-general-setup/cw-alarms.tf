resource "aws_cloudwatch_metric_alarm" "per_instance_alarms" {
  for_each = { for alarm in local.cw_alarms : alarm.name => alarm }

  alarm_name = each.key

  namespace           = each.value.namespace
  metric_name         = each.value.metric_name
  comparison_operator = each.value.operator
  evaluation_periods  = each.value.eval_periods
  period              = each.value.period_seconds
  statistic           = each.value.statistic
  threshold           = each.value.threshold

  dimensions = {
    InstanceId = each.value.instance_id
  }

  alarm_actions = [data.aws_sns_topic.cw_alarm_topic.arn]
}