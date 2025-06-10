variable "aws_region" {
  description = "Región de AWS donde se desplegarán los recursos"
  type        = string
  default     = "us-east-1"
  
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]{1}$", var.aws_region))
    error_message = "La región debe tener un formato válido, por ejemplo: us-east-1, eu-west-1, etc."
  }
}

variable "environment" {
  description = "Entorno de despliegue (dev, qa, pdn)"
  type        = string
  
  validation {
    condition     = contains(["dev", "qa", "pdn"], var.environment)
    error_message = "El entorno debe ser uno de: dev, qa, pdn."
  }
}

variable "client" {
  description = "Nombre del cliente"
  type        = string
  
  validation {
    condition     = length(var.client) > 0
    error_message = "El nombre del cliente no puede estar vacío."
  }
}

variable "project" {
  description = "Nombre del proyecto"
  type        = string
  
  validation {
    condition     = length(var.project) > 0
    error_message = "El nombre del proyecto no puede estar vacío."
  }
}

variable "cloudfront_config" {
  description = "Configuración de distribuciones CloudFront"
  type = map(object({
    oac_description      = string
    oac_origin           = string
    oac_signing_behavior = string
    oac_signing_protocol = string
    web_acl_id           = optional(string, "")
    comment              = string
    default_root_object  = string
    enabled              = bool
    http_version         = string
    aliases              = optional(list(string), [])
    price_class          = string
    custom_error_responses = optional(map(object({
      error_caching_min_ttl = string
      error_code            = string
      response_code         = string
      response_page_path    = string
    })), {})
    s3_origin = optional(map(object({
      domain_name = string
      origin_path = optional(string, "")
    })), {})
    lb_origin = optional(map(object({
      origin_path            = optional(string, "")
      http_port              = optional(number, 80)
      https_port             = optional(number, 443)
      origin_protocol_policy = optional(string, "https-only")
      origin_ssl_protocol    = optional(string, "TLSv1.2")
    })), {})
    default_allowed_methods            = list(string)
    default_cached_methods             = list(string)
    default_target_origin              = string
    default_viewer_protocol_policy     = string
    default_cache_policy_id            = string
    default_response_headers_policy_id = optional(string, "")
    default_origin_request_policy_id   = optional(string, "")
    default_compress                   = bool
    default_function_association = optional(map(object({
      event_type   = string
      function_arn = string
    })), {})
    ordered_cache_behavior = optional(map(object({
      path_pattern               = string
      allowed_methods            = list(string)
      cached_methods             = list(string)
      target_origin_id           = string
      viewer_protocol_policy     = string
      cache_policy_id            = string
      response_headers_policy_id = optional(string, "")
      compress                   = bool
      function_association = optional(map(object({
        event_type   = string
        function_arn = string
      })), {})
    })), {})
    origin_group = optional(map(object({
      status_codes = list(number)
      members      = map(string)
    })), {})
    viewer_certificate = optional(map(object({
      acm_certificate_arn      = string
      minimum_protocol_version = string
      ssl_support_method       = string
    })), {})
    logging_config = optional(map(object({
      bucket          = string
      include_cookies = bool
      prefix          = string
    })), {})
    restriction_type = string
    geo_restriction_locations = optional(list(string), [])
    application = optional(string, "")
    additional_tags  = optional(map(string), {})
  }))
  
  validation {
    condition     = length(var.cloudfront_config) > 0
    error_message = "Debe proporcionar al menos una configuración de CloudFront."
  }
  
  validation {
    condition = alltrue([
      for k, v in var.cloudfront_config : contains(["s3", "mediastore"], v.oac_origin)
    ])
    error_message = "El valor de oac_origin debe ser 's3' o 'mediastore'."
  }
  
  validation {
    condition = alltrue([
      for k, v in var.cloudfront_config : contains(["always", "never", "no-override"], v.oac_signing_behavior)
    ])
    error_message = "El valor de oac_signing_behavior debe ser 'always', 'never' o 'no-override'."
  }
  
  validation {
    condition = alltrue([
      for k, v in var.cloudfront_config : contains(["sigv4"], v.oac_signing_protocol)
    ])
    error_message = "El valor de oac_signing_protocol debe ser 'sigv4'."
  }
  
  validation {
    condition = alltrue([
      for k, v in var.cloudfront_config : contains(["http1.1", "http2", "http2and3", "http3"], v.http_version)
    ])
    error_message = "El valor de http_version debe ser 'http1.1', 'http2', 'http2and3' o 'http3'."
  }
  
  validation {
    condition = alltrue([
      for k, v in var.cloudfront_config : contains(["PriceClass_All", "PriceClass_200", "PriceClass_100"], v.price_class)
    ])
    error_message = "El valor de price_class debe ser 'PriceClass_All', 'PriceClass_200' o 'PriceClass_100'."
  }
  
  validation {
    condition = alltrue([
      for k, v in var.cloudfront_config : contains(["allow-all", "https-only", "redirect-to-https"], v.default_viewer_protocol_policy)
    ])
    error_message = "El valor de default_viewer_protocol_policy debe ser 'allow-all', 'https-only' o 'redirect-to-https'."
  }
  
  validation {
    condition = alltrue([
      for k, v in var.cloudfront_config : contains(["none", "whitelist", "blacklist"], v.restriction_type)
    ])
    error_message = "El valor de restriction_type debe ser 'none', 'whitelist' o 'blacklist'."
  }
  
  validation {
    condition = alltrue([
      for k, v in var.cloudfront_config : 
        v.restriction_type == "none" || 
        (v.restriction_type != "none" && length(v.geo_restriction_locations) > 0)
    ])
    error_message = "Si restriction_type es 'whitelist' o 'blacklist', geo_restriction_locations no puede estar vacío."
  }
  
  validation {
    condition = alltrue([
      for k, v in var.cloudfront_config : 
        length(v.s3_origin) > 0 || length(v.lb_origin) > 0
    ])
    error_message = "Debe proporcionar al menos un origen S3 o un origen de balanceador de carga."
  }
  
  validation {
    condition = alltrue([
      for k, v in var.cloudfront_config : 
        contains(keys(v.s3_origin), v.default_target_origin) || 
        contains(keys(v.lb_origin), v.default_target_origin)
    ])
    error_message = "El valor de default_target_origin debe ser una clave válida en s3_origin o lb_origin."
  }
}
