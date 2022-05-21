locals {
  region = data.aws_region.current.id
}

terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.14"
        }
    }
}

resource "aws_service_discovery_private_dns_namespace" "main" {
    name = "privatier.local"
    description = "service discovery for Privatier"
    vpc = module.vpc.vpc_id
}

resource "aws_appmesh_mesh" "main" {
    name = "privatier-local"
}

resource "aws_ecs_cluster" "main" {
    name = "main"
}

module "ecs-nginx" {
    source = "./modules/ecs-service"
    ## service details
    ecs_service_name = "nginx-dummy"
    task_image_url = "662716712905.dkr.ecr.eu-west-1.amazonaws.com/nginx:latest"
    ## cluster and vpc
    ecs_cluster_id = aws_ecs_cluster.main.id
    vpc_id = module.vpc.vpc_id
    ## service descovery
    service_registry_arn = aws_service_discovery_private_dns_namespace.main.arn
    service_registry_id = aws_service_discovery_private_dns_namespace.main.id
    namespace_name = aws_service_discovery_private_dns_namespace.main.name
    ## app mesh
    app_mesh_name = aws_appmesh_mesh.main.name
    app_mesh_arn = aws_appmesh_mesh.main.arn
}

module "ecs-gateway" {
    source = "./modules/ecs-gateway"
    ## service details
    ecs_service_name = "vg-main"
    ## cluster and vpc
    ecs_cluster_id = aws_ecs_cluster.main.id
    vpc_id = module.vpc.vpc_id
    ## service descovery
    service_registry_arn = aws_service_discovery_private_dns_namespace.main.arn
    service_registry_id = aws_service_discovery_private_dns_namespace.main.id
    namespace_name = aws_service_discovery_private_dns_namespace.main.name
    ## app mesh
    app_mesh_name = aws_appmesh_mesh.main.name
    app_mesh_arn = aws_appmesh_mesh.main.arn
    ## gateway routes
    gw_routes = {
      "nginx" = {
        match_prefix = "/"
        target_service = module.ecs-nginx.mesh_service_name
      }
    }

    depends_on = [
      module.ecs-nginx
    ]
}

module "apigw" {
    source = "./modules/apigw"
    public_hosted_zone = "net.rhizomatic.biz"
    vpc_link_security_groups = [ module.ecs-nginx.ecs_security_group_id ]
    vpc_link_subnets = module.vpc.public_subnets
    service_arn = module.ecs-gateway.discovery_service_arn

    depends_on = [
      module.ecs-gateway
    ]
}