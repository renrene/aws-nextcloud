resource "aws_service_discovery_private_dns_namespace" "main" {
    name = "privatier.local"
    description = "service discovery for Privatier"
    vpc = var.vpc_id
}