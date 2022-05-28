resource "aws_apigatewayv2_vpc_link" "main" {
    name = "vpc-link-main"
    security_group_ids = var.vpc_link_security_groups
    subnet_ids = var.vpc_link_subnets
}