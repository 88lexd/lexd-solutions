# CloudWatch logs groups for fluent-bit to push logs to
resource "aws_cloudwatch_log_group" "k8s_dataplane" {
  name              = "/aws/containerinsights/kubernetes/dataplane"
  retention_in_days = var.cw_log_k8s_dataplane_retention
}

resource "aws_cloudwatch_log_group" "k8s_application" {
  name              = "/aws/containerinsights/kubernetes/application"
  retention_in_days = var.cw_log_k8s_application_retention
}
