output "ecs_security_group_id" {
    value = aws_security_group.ecs.id
}

output "service_name" {
    value = aws_ecs_service.ngnix.name
}