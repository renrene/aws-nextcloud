resource "aws_apigatewayv2_domain_name" "main" {
    domain_name = local.custom_domain
    domain_name_configuration {
        certificate_arn = data.aws_acm_certificate.public.arn
        endpoint_type = "REGIONAL"
        security_policy = "TLS_1_2"
    }
}

resource "aws_route53_record" "api" {
    name = aws_apigatewayv2_domain_name.main.domain_name
    zone_id = data.aws_route53_zone.public.zone_id
    type = "A"

    alias {
        name = aws_apigatewayv2_domain_name.main.domain_name_configuration[0].target_domain_name
        zone_id = aws_apigatewayv2_domain_name.main.domain_name_configuration[0].hosted_zone_id
        evaluate_target_health = false
    }
}

resource "aws_apigatewayv2_api_mapping" "main" {
  api_id      = aws_apigatewayv2_api.main.id
  domain_name = aws_apigatewayv2_domain_name.main.id
  stage       = aws_apigatewayv2_stage.main.id
}