locals {
  # Generar nombres de recursos siguiendo la convención de nomenclatura estándar
  oac_names = {
    for k, v in var.cloudfront_config : k => "${var.client}-${var.project}-${var.environment}-oac-${k}"
  }
  
  # Crear un mapa para los nombres de orígenes VPC usando flatten para manejar los bucles anidados
  vpc_origin_names = {
    for pair in flatten([
      for cf_key, cf in var.cloudfront_config : [
        for lb_key, lb in cf.lb_origin : {
          key = "${cf_key}-${lb_key}"
          name = "${var.client}-${var.project}-${var.environment}-vpc-origin-${lb_key}"
        }
      ]
    ]) : pair.key => pair.name
  }
  
  # Aplanar los orígenes Lambda (Function URL) para crear un OAC por cada uno
  lambda_origins = {
    for pair in flatten([
      for cf_key, cf in var.cloudfront_config : [
        for lambda_key, lambda in cf.lambda_origin : {
          key        = "${cf_key}-${lambda_key}"
          cf_key     = cf_key
          lambda_key = lambda_key
          config     = lambda
        }
      ]
    ]) : pair.key => pair
  }
  oac_lambda_names = {
    for k, v in local.lambda_origins : k => "${var.client}-${var.project}-${var.environment}-oac-lambda-${v.cf_key}-${v.lambda_key}"
  }
  cloudfront_names = {
    for k, v in var.cloudfront_config : k => "${var.client}-${var.project}-${var.environment}-cloudfront-${k}"
  }
}