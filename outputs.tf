output "cloudfront_info" {
  value = {
    for name, cloudfront in aws_cloudfront_distribution.cloudfront : name => {
      "domain_name" : cloudfront.domain_name,
      "cloudfront_id" : cloudfront.id,
      "cloudfront_arn" : cloudfront.arn
    }
  }
}

output "oac_lambda_info" {
  description = "IDs y ARNs de los Origin Access Control de los orígenes Lambda, con clave <cloudfront>-<lambda_origin>"
  value = {
    for key, oac in aws_cloudfront_origin_access_control.oac_lambda : key => {
      "oac_id" : oac.id,
      "oac_arn" : oac.arn
    }
  }
}
