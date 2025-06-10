module "cloudfront" {
  source = "../"
  
  providers = {
    aws = aws.principal
  }
  
  client      = var.client
  project     = var.project
  environment = var.environment
  
  cloudfront_config = var.cloudfront_config
}
