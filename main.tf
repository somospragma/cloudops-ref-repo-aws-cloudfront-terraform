resource "aws_cloudfront_origin_access_control" "oac" {
  provider                          = aws.project
  for_each                          = var.cloudfront_config
  name                              = local.oac_names[each.key]
  description                       = each.value.oac_description
  origin_access_control_origin_type = each.value.oac_origin
  signing_behavior                  = each.value.oac_signing_behavior
  signing_protocol                  = each.value.oac_signing_protocol
}

resource "aws_cloudfront_vpc_origin" "lb" {
  provider = aws.project
  for_each = {
    for pair in flatten([
      for cf_key, cf in var.cloudfront_config : [
        for lb_key, lb in cf.lb_origin : {
          key    = "${cf_key}-${lb_key}"
          cf_key = cf_key
          lb_key = lb_key
          config = lb
        }
      ]
      ]) : pair.key => {
      cf_key = pair.cf_key
      lb_key = pair.lb_key
      config = pair.config
    }
  }

  vpc_origin_endpoint_config {
    name                   = local.vpc_origin_names[each.key]
    arn                    = data.aws_lb.lb[each.value.lb_key].arn
    http_port              = each.value.config.http_port
    https_port             = each.value.config.https_port
    origin_protocol_policy = each.value.config.origin_protocol_policy

    origin_ssl_protocols {
      items    = [each.value.config.origin_ssl_protocol]
      quantity = 1
    }
  }
}

resource "aws_cloudfront_distribution" "cloudfront" {
  provider = aws.project
  # checkov:skip=CKV_AWS_216: Se hace envío del enabled desde variables
  # checkov:skip=CKV2_AWS_32: Se hace envio del response header desde variables
  # checkov:skip=CKV2_AWS_47: Se hace envío del web_acl desde variables
  # checkov:skip=CKV_AWS_174: Se hace envío de la versión mínima de tls por medio de variables 
  for_each            = var.cloudfront_config
  web_acl_id          = each.value.web_acl_id
  comment             = each.value.comment
  default_root_object = each.value.default_root_object
  enabled             = each.value.enabled
  http_version        = each.value.http_version
  aliases             = each.value.aliases
  price_class         = each.value.price_class

  dynamic "custom_error_response" {
    for_each = each.value.custom_error_responses
    content {
      error_caching_min_ttl = custom_error_response.value["error_caching_min_ttl"]
      error_code            = custom_error_response.value["error_code"]
      response_code         = custom_error_response.value["response_code"]
      response_page_path    = custom_error_response.value["response_page_path"]
    }
  }

  dynamic "origin" { //Origins de s3
    for_each = each.value.s3_origin
    content {
      origin_id                = origin.key
      domain_name              = origin.value["domain_name"]
      origin_path              = origin.value["origin_path"]
      origin_access_control_id = aws_cloudfront_origin_access_control.oac[each.key].id
    }
  }

  dynamic "origin" { //Origins de vpc
    for_each = each.value.lb_origin
    content {
      origin_id   = origin.key
      domain_name = data.aws_lb.lb[origin.key].dns_name
      origin_path = origin.value["origin_path"]
      vpc_origin_config {
        vpc_origin_id = aws_cloudfront_vpc_origin.lb["${each.key}-${origin.key}"].id
      }
    }
  }

  default_cache_behavior {
    allowed_methods            = each.value.default_allowed_methods
    cached_methods             = each.value.default_cached_methods
    target_origin_id           = each.value.default_target_origin
    viewer_protocol_policy     = each.value.default_viewer_protocol_policy
    cache_policy_id            = each.value.default_cache_policy_id
    origin_request_policy_id   = each.value.default_origin_request_policy_id
    response_headers_policy_id = each.value.default_response_headers_policy_id
    compress                   = each.value.default_compress
    dynamic "function_association" {
      for_each = each.value.default_function_association
      content {
        event_type   = function_association.value["event_type"]
        function_arn = function_association.value["function_arn"]
      }
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = each.value.ordered_cache_behavior
    content {
      path_pattern               = ordered_cache_behavior.value["path_pattern"]
      allowed_methods            = ordered_cache_behavior.value["allowed_methods"]
      cached_methods             = ordered_cache_behavior.value["cached_methods"]
      target_origin_id           = ordered_cache_behavior.value["target_origin_id"]
      viewer_protocol_policy     = ordered_cache_behavior.value["viewer_protocol_policy"]
      cache_policy_id            = ordered_cache_behavior.value["cache_policy_id"]
      response_headers_policy_id = ordered_cache_behavior.value["response_headers_policy_id"]
      compress                   = ordered_cache_behavior.value["compress"]
      dynamic "function_association" {
        for_each = ordered_cache_behavior.value["function_association"]
        content {
          event_type   = function_association.value["event_type"]
          function_arn = function_association.value["function_arn"]
        }
      }
    }
  }

  dynamic "viewer_certificate" {
    for_each = each.value.viewer_certificate
    content {
      acm_certificate_arn            = viewer_certificate.value["acm_certificate_arn"]
      cloudfront_default_certificate = viewer_certificate.value["acm_certificate_arn"] == "" ? true : false
      minimum_protocol_version       = viewer_certificate.value["minimum_protocol_version"]
      ssl_support_method             = viewer_certificate.value["ssl_support_method"]
    }
  }

  dynamic "logging_config" {
    for_each = each.value.logging_config
    content {
      bucket          = logging_config.value["bucket"]
      include_cookies = logging_config.value["include_cookies"]
      prefix          = logging_config.value["prefix"]
    }
  }

  dynamic "origin_group" {
    for_each = each.value.origin_group
    content {
      origin_id = origin_group.key
      failover_criteria {
        status_codes = origin_group.value["status_codes"]
      }

      dynamic "member" {
        for_each = origin_group.value["members"]
        content {
          origin_id = member.key
        }
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = each.value.restriction_type
      locations        = each.value.geo_restriction_locations
    }
  }

  tags = merge(
    {
      Name        = local.cloudfront_names[each.key]
      Application = each.value.application != "" ? each.value.application : null
    },
    each.value.additional_tags
  )
}
