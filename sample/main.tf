module "cloudfront" {
  source = "../"
  providers = {
    aws.project = aws.principal
  }
  client      = var.client
  project     = var.project
  environment = var.environment
  cloudfront_config = var.cloudfront_config
}

# El permiso de invocación de la Function URL NO lo crea el módulo (PC-IAC-023).
# Se crea por aparte para que CloudFront (OAC) pueda invocar la Lambda.
resource "aws_lambda_permission" "cloudfront_invoke_url" {
  provider               = aws.principal
  count                  = var.lambda_function_name != "" ? 1 : 0
  statement_id           = "AllowCloudFrontServicePrincipal"
  action                 = "lambda:InvokeFunctionUrl"
  function_name          = var.lambda_function_name
  principal              = "cloudfront.amazonaws.com"
  source_arn             = module.cloudfront.cloudfront_info[var.lambda_distribution_key].cloudfront_arn
  function_url_auth_type = "AWS_IAM"
}
