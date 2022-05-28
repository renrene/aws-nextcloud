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
    backend "s3" {
        bucket = "privatier-tf-state-backend"
        key = "shared"
        profile = "privatier"
        region = "eu-west-1"
    }
}


resource "aws_service_discovery_private_dns_namespace" "main" {
    name = "privatier.local"
    description = "service discovery for Privatier"
    vpc = module.vpc.vpc_id
}

resource "aws_appmesh_mesh" "main" {
    name = "privatier-local"
    spec {
      egress_filter {
        type = "ALLOW_ALL"
      }
    }
}

module "ecs-gateway" {
    source = "./modules/ecs-gateway"
    ## vpc
    vpc_id = module.vpc.vpc_id
    ## service descovery
    service_registry_arn = aws_service_discovery_private_dns_namespace.main.arn
    service_registry_id = aws_service_discovery_private_dns_namespace.main.id
    namespace_name = aws_service_discovery_private_dns_namespace.main.name
    ## app mesh
    app_mesh_name = aws_appmesh_mesh.main.name
    app_mesh_arn = aws_appmesh_mesh.main.arn
}

module "apigw" {
    source = "./modules/apigw"
    public_hosted_zone = "net.rhizomatic.biz"
    vpc_link_security_groups = [ module.ecs-gateway.ecs_security_group_id ]
    vpc_link_subnets = module.vpc.public_subnets
    service_arn = module.ecs-gateway.discovery_service_arn

    depends_on = [
      module.ecs-gateway
    ]
}