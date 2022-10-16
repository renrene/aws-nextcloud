output "vpc" {
    value = { for k,v in module.vpc : k => v }
    description = "The VPC object"
}

output "appmesh" {
    value = { for k,v in aws_appmesh_mesh.main : k => v }
    description = "The AppMesh object"
}

output "namespace" {
    value = { for k,v in aws_service_discovery_private_dns_namespace.main : k => v }
    description = "The CloudMap namespace object"
}

output "ecs_cluster" {
    value = { for k,v in module.ecs-cluster.ecs_cluster : k => v }
    description = "The ECS Cluster object"
}

output "gateway_service_name" {
    value = module.ecs-gateway.service_name
    description = "Virtual-Gateway discoverable service name"
}

output "apigw_domain_name" {
    value = module.apigw.apigw_domain
    description = "Public domain mapping of API-GW"
}

output "ami-id" {
    value = data.aws_ami.latest-ecs-optimized.id
}
