output "cloudfront_info" {
  value = {
    for name, cloudfront in aws_cloudfront_distribution.cloudfront : name => {
      "domain_name" : cloudfront.domain_name,
      "cloudfront_id" : cloudfront.id,
      "cloudfront_arn" : cloudfront.arn
    }
  }
}
