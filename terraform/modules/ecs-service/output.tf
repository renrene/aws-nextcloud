output "ecs_security_group_id" {
    value = aws_security_group.ecs.id
}

output "service_name" {
    value = aws_ecs_service.main.name
}

output "discovery_service_arn" {
    value = aws_service_discovery_service.main.arn  
}

output "mesh_service_name" {
    value = aws_appmesh_virtual_service.main.name
}
