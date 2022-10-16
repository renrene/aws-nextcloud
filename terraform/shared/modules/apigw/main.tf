locals {
    custom_domain = "api.${data.aws_route53_zone.public.name}"    
    acm_domain = "*.${data.aws_route53_zone.public.name}"
    region = data.aws_region.current.id
    account = data.aws_caller_identity.current.account_id
}

resource "aws_apigatewayv2_api" "main" {
    name = "api-gw-nextcloud"
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

resource "aws_apigatewayv2_route" "main" {
    api_id = aws_apigatewayv2_api.main.id
    route_key = "ANY /{proxy+}"
    target = "integrations/${aws_apigatewayv2_integration.main.id}"
  
}

resource "aws_apigatewayv2_stage" "main" {
    api_id = aws_apigatewayv2_api.main.id
    name = "$default"
    auto_deploy = true
  
}