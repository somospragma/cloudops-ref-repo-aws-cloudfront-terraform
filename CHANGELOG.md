# Changelog

Todos los cambios notables en este proyecto serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
