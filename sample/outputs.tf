output "cloudfront_info" {
  description = "Información sobre las distribuciones CloudFront creadas"
  value       = module.cloudfront.cloudfront_info
}
output "oac_lambda_info" {
  description = "IDs y ARNs de los OAC de los orígenes Lambda"
  value       = module.cloudfront.oac_lambda_info
}
