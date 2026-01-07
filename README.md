# Módulo Terraform: AWS CloudFront

## Descripción

Este módulo permite la creación y gestión de distribuciones CloudFront en AWS, soportando múltiples configuraciones como orígenes S3, orígenes de VPC (ALB), comportamientos de caché personalizados, certificados SSL/TLS, y más. El módulo está diseñado para ser flexible y adaptarse a diferentes casos de uso mientras sigue las mejores prácticas de seguridad y rendimiento.

Para ver el historial de cambios, consulte el [CHANGELOG.md](./CHANGELOG.md).

Se recomienda fijar la versión del módulo en sus implementaciones:
```hcl
module "cloudfront" {
  source = "git::https://github.com/somospragma/cloudops-ref-repo-aws-cloudfront-terraform.git?ref=v1.0.0"
  # Configuración...
}
```

## Características

- ✅ Soporte para múltiples distribuciones CloudFront
- ✅ Configuración de orígenes S3 con Origin Access Control (OAC)
- ✅ Configuración de orígenes VPC (ALB)
- ✅ Configuración de orígenes DNS personalizados (HTTPS endpoints)
- ✅ Comportamientos de caché personalizados
- ✅ Certificados SSL/TLS con ACM
- ✅ Configuración de logs
- ✅ Integración con AWS WAF
- ✅ Grupos de origen para failover
- ✅ Asociación de funciones CloudFront
- ✅ Restricciones geográficas

## Implementación y Configuración

### Requisitos Técnicos

| Nombre | Versión |
|--------|---------|
| terraform | >= 1.0.0 |
| aws | >= 4.31.0 |

### Provider Configuration

```hcl
provider "aws" {
  region = "us-east-1"
  alias  = "principal"
  
  default_tags {
    tags = {
      environment = var.environment
      project     = var.project
      owner       = "cloudops"
      client      = var.client
      area        = "infrastructure"
      provisioned = "terraform"
      datatype    = "operational"
    }
  }
}

module "cloudfront" {
  source = "git::https://github.com/somospragma/cloudops-ref-repo-aws-cloudfront-terraform.git?ref=v1.0.0"
  
  providers = {
    aws.project = aws.principal
  }
  
  # Resto de la configuración...
}
```

### Recursos Gestionados

| Nombre | Tipo |
|--------|------|
| aws_cloudfront_distribution | Distribución CloudFront |
| aws_cloudfront_origin_access_control | Control de acceso de origen para S3 |
| aws_cloudfront_vpc_origin | Origen VPC para ALB |

### Parámetros de Entrada

| Nombre | Descripción | Tipo | Default | Requerido |
|--------|-------------|------|---------|:---------:|
| cloudfront_config | Configuración de distribuciones CloudFront | `map(object(...))` | n/a | sí |
| domain | Nombre del dominio principal para la distribución CloudFront | `string` | n/a | sí |
| subdomain | Nombre del subdominio para la distribución CloudFront | `string` | n/a | sí |
| environment | Entorno en el que se desplegará la distribución CloudFront (dev, qa, pdn) | `string` | n/a | sí |
| additional_tags | Etiquetas adicionales para todos los recursos creados por el módulo | `map(string)` | `{}` | no |

### Estructura de Configuración

La variable `cloudfront_config` tiene la siguiente estructura:

```hcl
variable "cloudfront_config" {
  description = "Configuración de distribuciones CloudFront"
  type = map(object({
    oac_description      = string       # Descripción del Origin Access Control
    oac_origin           = string       # Tipo de origen para OAC (s3)
    oac_signing_behavior = string       # Comportamiento de firma (always, never, no-override)
    oac_signing_protocol = string       # Protocolo de firma (sigv4)
    web_acl_id           = optional(string, "") # ID de la ACL de WAF (opcional)
    comment              = string       # Comentario para la distribución
    default_root_object  = string       # Objeto raíz predeterminado
    enabled              = bool         # Habilitar/deshabilitar la distribución
    http_version         = string       # Versión HTTP (http1.1, http2, http3)
    aliases              = optional(list(string), []) # Nombres de dominio alternativos
    price_class          = string       # Clase de precio (PriceClass_All, PriceClass_200, PriceClass_100)
    
    # Configuración de respuestas de error personalizadas
    custom_error_responses = list(object({
      error_caching_min_ttl = string    # TTL mínimo para el error en caché
      error_code            = string    # Código de error HTTP
      response_code         = string    # Código de respuesta HTTP
      response_page_path    = string    # Ruta a la página de error personalizada
    }))
    
    # Configuración de orígenes S3
    s3_origin = list(object({
      domain_name = string              # Nombre de dominio del bucket S3
      origin_id   = string              # ID único para el origen
      origin_path = string              # Ruta dentro del bucket
    }))
    
    # Configuración de orígenes ALB
    lb_origin = list(object({
      origin_path            = string   # Ruta en el origen
      alb_name               = string   # Nombre del ALB
      http_port              = number   # Puerto HTTP
      https_port             = number   # Puerto HTTPS
      origin_protocol_policy = string   # Política de protocolo (http-only, https-only, match-viewer)
      origin_ssl_protocol    = string   # Protocolo SSL (TLSv1, TLSv1.1, TLSv1.2)
    }))
    
    # Configuración de orígenes DNS personalizados
    dns_origin = list(object({
      domain_name              = string              # Nombre de dominio del endpoint HTTPS
      origin_path              = string              # Ruta en el origen
      http_port                = number              # Puerto HTTP
      https_port               = number              # Puerto HTTPS
      origin_protocol_policy   = string              # Política de protocolo (https-only recomendado)
      origin_ssl_protocols     = list(string)        # Protocolos SSL soportados
      origin_keepalive_timeout = number              # Timeout de keepalive en segundos
      origin_read_timeout      = number              # Timeout de lectura en segundos
      custom_headers           = map(string)         # Encabezados personalizados
    }))
    
    # Configuración del comportamiento de caché predeterminado
    default_allowed_methods            = list(string) # Métodos HTTP permitidos
    default_cached_methods             = list(string) # Métodos HTTP en caché
    default_target_origin              = string       # ID del origen predeterminado
    default_viewer_protocol_policy     = string       # Política de protocolo (redirect-to-https, https-only, allow-all)
    default_cache_policy_id            = string       # ID de la política de caché
    default_response_headers_policy_id = string       # ID de la política de encabezados de respuesta
    default_origin_request_policy_id   = string       # ID de la política de solicitud de origen
    default_compress                   = bool         # Comprimir respuestas
    
    # Asociación de funciones para el comportamiento predeterminado
    default_function_association = list(object({
      event_type   = string             # Tipo de evento (viewer-request, viewer-response, origin-request, origin-response)
      function_arn = string             # ARN de la función
    }))
    
    # Comportamientos de caché ordenados
    ordered_cache_behavior = list(object({
      path_pattern               = string        # Patrón de ruta
      allowed_methods            = list(string)  # Métodos HTTP permitidos
      cached_methods             = list(string)  # Métodos HTTP en caché
      target_origin_id           = string        # ID del origen
      viewer_protocol_policy     = string        # Política de protocolo
      cache_policy_id            = string        # ID de la política de caché
      response_headers_policy_id = string        # ID de la política de encabezados de respuesta
      compress                   = bool          # Comprimir respuestas
      
      # Asociación de funciones para este comportamiento
      function_association = list(object({
        event_type   = string               # Tipo de evento
        function_arn = string               # ARN de la función
      }))
    }))
    
    # Configuración de grupos de origen para failover
    origin_group = list(object({
      origin_id    = string                # ID del grupo de origen
      status_codes = list(number)          # Códigos de estado para failover
      members      = map(string)           # Miembros del grupo (mapa de ID de origen)
    }))
    
    # Configuración del certificado SSL/TLS
    viewer_certificate = list(object({
      acm_certificate_arn      = string    # ARN del certificado ACM
      minimum_protocol_version = string    # Versión mínima del protocolo TLS
      ssl_support_method       = string    # Método de soporte SSL (sni-only, vip)
    }))
    
    # Configuración de logs
    logging_config = list(object({
      bucket          = string             # Bucket S3 para logs
      include_cookies = bool               # Incluir cookies en logs
      prefix          = string             # Prefijo para los logs
    }))
    
    # Configuración de restricciones geográficas
    restriction_type = string              # Tipo de restricción (none, whitelist, blacklist)
    
    # Etiquetas adicionales específicas para esta distribución
    additional_tags  = optional(map(string), {})
  }))
}
```

### Valores de Salida

| Nombre | Descripción |
|--------|-------------|
| cloudfront_info | Información sobre las distribuciones CloudFront creadas, incluyendo domain_name, cloudfront_id y cloudfront_arn |

### Ejemplos de Uso

#### Ejemplo Básico con Origen S3

```hcl
module "cloudfront" {
  source = "git::https://github.com/somospragma/cloudops-ref-repo-aws-cloudfront-terraform.git?ref=v1.0.0"
  
  providers = {
    aws.project = aws.principal
  }
  
  domain      = "example"
  subdomain   = "app"
  environment = "dev"
  
  cloudfront_config = {
    main = {
      oac_description      = "OAC para acceso a S3"
      oac_origin           = "s3"
      oac_signing_behavior = "always"
      oac_signing_protocol = "sigv4"
      comment              = "Distribución para aplicación web"
      default_root_object  = "index.html"
      enabled              = true
      http_version         = "http2"
      price_class          = "PriceClass_100"
      
      custom_error_responses = []
      
      s3_origin = [{
        domain_name = "example-bucket.s3.amazonaws.com"
        origin_id   = "s3-example"
        origin_path = ""
      }]
      
      lb_origin = []
      dns_origin = []
      
      default_allowed_methods        = ["GET", "HEAD", "OPTIONS"]
      default_cached_methods         = ["GET", "HEAD"]
      default_target_origin          = "s3-example"
      default_viewer_protocol_policy = "redirect-to-https"
      default_cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6" # CachingOptimized
      default_origin_request_policy_id = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf" # CORS-S3Origin
      default_response_headers_policy_id = ""
      default_compress               = true
      default_function_association   = []
      
      ordered_cache_behavior = []
      origin_group = []
      
      viewer_certificate = [{
        acm_certificate_arn      = ""
        minimum_protocol_version = "TLSv1.2_2021"
        ssl_support_method       = "sni-only"
      }]
      
      logging_config = []
      restriction_type = "none"
    }
  }
  
  additional_tags = {
    Project = "WebApp"
  }
}
```

#### Ejemplo con Origen DNS (API Gateway/Bedrock)

```hcl
module "cloudfront_api" {
  source = "git::https://github.com/somospragma/cloudops-ref-repo-aws-cloudfront-terraform.git?ref=v1.1.0"
  
  providers = {
    aws.project = aws.principal
  }
  
  domain      = "api"
  subdomain   = "bedrock"
  environment = "dev"
  
  cloudfront_config = {
    api_gateway = {
      oac_description      = "OAC para API Gateway"
      oac_origin           = "s3"
      oac_signing_behavior = "always"
      oac_signing_protocol = "sigv4"
      comment              = "Distribución para Bedrock API Gateway"
      default_root_object  = ""
      enabled              = true
      http_version         = "http2"
      price_class          = "PriceClass_100"
      
      custom_error_responses = []
      s3_origin = []
      lb_origin = []
      
      dns_origin = [{
        domain_name              = "pra-jvs-dev-agentcore-gateway.gateway.bedrock-agentcore.us-east-1.amazonaws.com"
        origin_path              = ""
        origin_protocol_policy   = "https-only"
        origin_ssl_protocols     = ["TLSv1.2"]
        https_port               = 443
        origin_keepalive_timeout = 5
        origin_read_timeout      = 30
        custom_headers = {
          "X-Forwarded-Host" = "api.bedrock.example.com"
        }
      }]
      
      default_allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      default_cached_methods         = ["GET", "HEAD"]
      default_target_origin          = "bedrock-api"
      default_viewer_protocol_policy = "redirect-to-https"
      default_cache_policy_id        = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # CachingDisabled
      default_origin_request_policy_id = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf" # CORS-S3Origin
      default_response_headers_policy_id = ""
      default_compress               = true
      default_function_association   = []
      
      ordered_cache_behavior = []
      origin_group = []
      
      viewer_certificate = [{
        acm_certificate_arn      = "arn:aws:acm:us-east-1:123456789012:certificate/example"
        minimum_protocol_version = "TLSv1.2_2021"
        ssl_support_method       = "sni-only"
      }]
      
      logging_config = []
      restriction_type = "none"
    }
  }
  
  additional_tags = {
    Project = "BedrockAPI"
  }
}
```

## Consideraciones Operativas

### Rendimiento y Escalabilidad

- CloudFront se escala automáticamente para manejar picos de tráfico
- La elección de `price_class` afecta la cobertura global y el rendimiento
- Considere usar políticas de caché optimizadas para mejorar el rendimiento

### Limitaciones y Restricciones

- Algunas características como Lambda@Edge no están incluidas en este módulo
- Las políticas de caché y encabezados deben crearse previamente
- Los certificados ACM deben estar en la región us-east-1 para CloudFront

### Costos y Optimización

- El costo varía según el `price_class`, el volumen de transferencia y las solicitudes
- Utilice la compresión para reducir los costos de transferencia
- Configure TTLs adecuados para optimizar el uso de la caché

## Seguridad y Cumplimiento

### Consideraciones de seguridad

- Se recomienda usar TLSv1.2_2021 o superior como versión mínima del protocolo
- Implemente AWS WAF para protección adicional contra amenazas web
- Utilice OAC para acceso seguro a buckets S3
- Configure políticas de encabezados de respuesta para mejorar la seguridad del navegador

### Mejores Prácticas Implementadas

- Uso de Origin Access Control (OAC) para S3
- Soporte para integración con AWS WAF
- Configuración de TLS para conexiones seguras
- Redirección HTTPS para tráfico seguro

## Lista de verificación de cumplimiento

- [x] Nomenclatura de recursos conforme al estándar
- [x] Etiquetas obligatorias aplicadas a todos los recursos
- [x] Validaciones para garantizar configuraciones correctas
- [x] Soporte para TLS 1.2 o superior
- [x] Integración con AWS WAF
- [x] Configuración de logs para auditoría
