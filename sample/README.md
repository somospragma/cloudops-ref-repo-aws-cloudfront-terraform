# Ejemplo de implementación del módulo AWS CloudFront

Este ejemplo muestra cómo implementar el módulo de CloudFront para crear una distribución que sirve contenido desde un bucket S3.

## Estructura de archivos

- `main.tf`: Configuración principal que implementa el módulo de CloudFront
- `variables.tf`: Definición de variables utilizadas en el ejemplo
- `outputs.tf`: Salidas del ejemplo
- `terraform.auto.tfvars.sample`: Ejemplo de archivo de variables (renombrar a terraform.auto.tfvars para usar)

## Requisitos previos

- Terraform v1.0.0 o superior
- AWS CLI configurado con credenciales válidas
- Permisos IAM para crear recursos CloudFront, OAC y acceder a buckets S3
- Un bucket S3 existente con contenido web

## Cómo usar este ejemplo

1. Clona el repositorio y navega al directorio del ejemplo:
   ```bash
   cd sample/
   ```

2. Copia el archivo de variables de ejemplo y personalízalo:
   ```bash
   cp terraform.auto.tfvars.sample terraform.auto.tfvars
   # Edita terraform.auto.tfvars con tus valores
   ```

3. Inicializa Terraform:
   ```bash
   terraform init
   ```

4. Verifica el plan de Terraform:
   ```bash
   terraform plan
   ```

5. Aplica la configuración:
   ```bash
   terraform apply
   ```

6. Verifica los recursos creados:
   ```bash
   terraform output cloudfront_info
   ```

## Escenarios incluidos

### Distribución CloudFront con origen S3

Este ejemplo crea una distribución CloudFront que sirve contenido desde un bucket S3 utilizando Origin Access Control (OAC) para un acceso seguro.

Características configuradas:
- OAC para acceso seguro al bucket S3
- Redirección de HTTP a HTTPS
- Compresión de contenido
- Política de caché optimizada
- TLS 1.2 como versión mínima del protocolo

## Limpieza

Para eliminar todos los recursos creados:

```bash
terraform destroy
```
