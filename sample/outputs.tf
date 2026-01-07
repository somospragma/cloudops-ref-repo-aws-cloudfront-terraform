output "cloudfront_info" {
  description = "Información sobre las distribuciones CloudFront creadas"
  value       = module.cloudfront.cloudfront_info
}
