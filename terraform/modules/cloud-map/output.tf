output "namespace_id" {
    value = aws_service_discovery_private_dns_namespace.main.id
}

output "namespace_arn" {
    value = aws_service_discovery_private_dns_namespace.main.arn
}

output "namespace_name" {
    value = aws_service_discovery_private_dns_namespace.main.name
}