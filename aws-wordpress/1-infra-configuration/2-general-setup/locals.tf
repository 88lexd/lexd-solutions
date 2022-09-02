locals {
  cw_alarms = [
    {
      name           = "Master Node - Instance Status Check",
      namespace      = "AWS/EC2",
      metric_name    = "StatusCheckFailed_Instance",
      operator       = "GreaterThanOrEqualToThreshold",
      eval_periods   = "2",
      period_seconds = "300",
      statistic      = "Average",
      threshold      = "0.5",
      instance_id    = data.aws_instance.k8s_master.id
    },
    {
      name           = "Worker Node - Instance Status Check",
      namespace      = "AWS/EC2",
      metric_name    = "StatusCheckFailed_Instance",
      operator       = "GreaterThanOrEqualToThreshold",
      eval_periods   = "2",
      period_seconds = "300",
      statistic      = "Average",
      threshold      = "0.5",
      instance_id    = data.aws_instance.k8s_worker.id
    }
  ]
}