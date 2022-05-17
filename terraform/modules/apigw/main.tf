locals {
    custom_domain = "api.${data.aws_route53_zone.public.name}"    
    acm_domain = "*.${data.aws_route53_zone.public.name}"
    region = data.aws_region.current.id
    account = data.aws_caller_identity.current.account_id
}

resource "aws_apigatewayv2_vpc_link" "main" {
    name = "vpc-link-main"
    security_group_ids = var.vpc_link_security_groups
    subnet_ids = var.vpc_link_subnets
}



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

resource "aws_apigatewayv2_api" "main" {
    name = "api-gw-privatier"
    protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "main" {
    api_id = aws_apigatewayv2_api.main.id
    integration_type = "HTTP_PROXY"
    integration_uri = var.service_arn

    integration_method = "ANY"
    connection_type = "VPC_LINK"
    connection_id = aws_apigatewayv2_vpc_link.main.id
  
}