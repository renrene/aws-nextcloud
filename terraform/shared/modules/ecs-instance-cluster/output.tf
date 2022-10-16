output "ecs_cluster" {
    value = { for k,v in aws_ecs_cluster.main : k => v }
    description = "The ECS Cluster object"
}