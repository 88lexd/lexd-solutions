# module "lambda_function_container_image" {
#   source = "terraform-aws-modules/lambda/aws"

#   function_name = var.lambda_func_name
#   description = var.lambda_func_description

#   create_package = false

#   image_uri = var.lambda_ecr_image_uri
#   package_type = "Image"

#   cloudwatch_logs_retention_in_days = var.lambda_cw_logs_retention

#   environment_variables = var.lambda_environment_variables

#   attach_policy_json = true
#   policy_json = jsonencode(var.lambda_policy_json)
# }
