data "aws_lb" "lb" {
  for_each = {
    for pair in flatten([
      for cf_key, cf in var.cloudfront_config : [
        for lb_key, lb in cf.lb_origin : {
          key = lb_key
          config = lb
        }
      ]
    ]) : pair.key => pair.config
  }
  name = each.key
}
