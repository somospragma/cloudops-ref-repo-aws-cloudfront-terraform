# Changelog

Todos los cambios notables en este proyecto serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
