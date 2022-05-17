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

module "cloud-map" {
  source = "./modules/cloud-map"
  vpc_id = module.vpc.vpc_id
}

module "app-mesh" {
    source = "./modules/app-mesh"
}

module "ecs-ngnix" {
    source = "./modules/ecs-ngnix"
    vpc_id = module.vpc.vpc_id
    service_registry_arn = module.cloud-map.namespace_arn
    service_registry_id = module.cloud-map.namespace_id
    app_mesh_name = module.app-mesh.mesh_name
    namespace_name = module.cloud-map.namespace_name
}

module "apigw" {
    source = "./modules/apigw"
    vpc_link_security_groups = [ module.ecs-ngnix.ecs_security_group_id ]
    vpc_link_subnets = module.vpc.public_subnets
    public_hosted_zone = "net.rhizomatic.biz"
    service_arn = module.ecs-ngnix.discovery_service_arn
}