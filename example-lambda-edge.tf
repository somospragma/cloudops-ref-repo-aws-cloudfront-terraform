module "cloudfront_with_lambda" {
  source = "./"
  
  client      = "pragma"
  project     = "lambda-edge"
  environment = "dev"
  
  cloudfront_config = {
    main = {
      oac_description      = "OAC for S3 with Lambda@Edge"
      oac_origin           = "s3"
      oac_signing_behavior = "always"
      oac_signing_protocol = "sigv4"
      comment              = "CloudFront with Lambda@Edge functions"
      default_root_object  = "index.html"
      enabled              = true
      http_version         = "http2"
      price_class          = "PriceClass_100"
      
      custom_error_responses = {}
      lb_origin = {}
      dns_origin = {}
      
      s3_origin = {
        main = {
          domain_name = "example-bucket.s3.amazonaws.com"
          origin_path = ""
        }
      }
      
      default_allowed_methods        = ["GET", "HEAD", "OPTIONS"]
      default_cached_methods         = ["GET", "HEAD"]
      default_target_origin          = "main"
      default_viewer_protocol_policy = "redirect-to-https"
      default_cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
      default_compress               = true
      
      # CloudFront Functions (lightweight)
      default_function_association = {
        viewer_request = {
          event_type   = "viewer-request"
          function_arn = "arn:aws:cloudfront::123456789012:function/example-function"
        }
      }
      
      # Lambda@Edge Functions (full Lambda)
      default_lambda_function_association = {
        origin_response = {
          event_type   = "origin-response"
          lambda_arn   = "arn:aws:lambda:us-east-1:123456789012:function:example-lambda:1"
          include_body = false
        }
      }
      
      # Different functions for specific paths
      ordered_cache_behavior = {
        api = {
          path_pattern           = "/api/*"
          allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
          cached_methods         = ["GET", "HEAD"]
          target_origin_id       = "main"
          viewer_protocol_policy = "https-only"
          cache_policy_id        = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
          compress               = true
          
          function_association = {}
          lambda_function_association = {
            viewer_request = {
              event_type   = "viewer-request"
              lambda_arn   = "arn:aws:lambda:us-east-1:123456789012:function:api-auth:2"
              include_body = true
            }
          }
        }
      }
      
      origin_group = {}
      
      viewer_certificate = {
        default = {
          acm_certificate_arn      = ""
          minimum_protocol_version = "TLSv1.2_2021"
          ssl_support_method       = "sni-only"
        }
      }
      
      logging_config = {}
      restriction_type = "none"
      geo_restriction_locations = []
    }
  }
}
