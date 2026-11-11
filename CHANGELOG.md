# Changelog

Todos los cambios notables en este proyecto serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.0] - 2026-11-11
### Añadido
- Soporte para orígenes Lambda Function URL protegidos con OAC (`lambda_origin`)
- Recurso `aws_cloudfront_origin_access_control.oac_lambda` (tipo `lambda`), un OAC por cada `lambda_origin`
- Output `oac_lambda_info` con IDs y ARNs de los OAC de Lambda
- Validaciones de `lambda_origin` (hostname sin esquema, firma `sigv4`) y de `default_target_origin`
### Cambiado
- Versión mínima del provider AWS: `>= 5.82.0` (soporte OAC tipo `lambda` desde 5.46.0 y `aws_cloudfront_vpc_origin` desde 5.82.0)
### Notas
- El `aws_lambda_permission` que autoriza a CloudFront a invocar la Function URL NO es gestionado por el módulo (PC-IAC-023); debe crearse por aparte
## [1.2.0] - 2026-01-07

### Añadido
- Soporte para Lambda@Edge functions (`lambda_function_association`)
- Configuración de `include_body` para Lambda@Edge functions
- Validaciones para event types de Lambda@Edge
- Soporte para Lambda@Edge en comportamientos de caché ordenados

### Cambiado
- Documentación actualizada con ejemplos de Lambda@Edge vs CloudFront Functions

## [1.1.0] - 2026-01-07

### Añadido
- Soporte para orígenes DNS personalizados (`dns_origin`)
- Configuración de `custom_origin_config` para endpoints HTTPS externos
- Soporte para encabezados personalizados en orígenes DNS
- Configuración de timeouts para orígenes DNS (keepalive y read)
- Validaciones actualizadas para incluir orígenes DNS

### Cambiado
- Validaciones de origen actualizadas para soportar tres tipos: S3, ALB y DNS
- Documentación actualizada con ejemplos de uso para orígenes DNS

## [1.0.0] - 2025-06-05

### Añadido
- Implementación inicial del módulo de CloudFront
- Soporte para orígenes S3 con Origin Access Control (OAC)
- Soporte para orígenes VPC (ALB)
- Configuración de comportamientos de caché personalizados
- Integración con AWS WAF
- Configuración de certificados SSL/TLS
- Configuración de logs
- Grupos de origen para failover
- Asociación de funciones CloudFront
- Restricciones geográficas

### Cambiado
- Migración de lista de objetos a mapa de objetos para la variable `cloudfront_config`
- Implementación del sistema de etiquetado en tres niveles

### Corregido
- Validación de variables para garantizar valores correctos
