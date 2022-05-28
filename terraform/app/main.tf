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
    spec {
      egress_filter {
        type = "ALLOW_ALL"
      }
    }
}

resource "aws_ecs_cluster" "main" {
    name = "main"
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
    vpc_link_security_groups = [ module.ecs-nginx.ecs_security_group_id ]
    vpc_link_subnets = module.vpc.public_subnets
    service_arn = module.ecs-gateway.discovery_service_arn

    depends_on = [
      module.ecs-gateway
    ]
}

module "ecs-nginx" {
    source = "./modules/ecs-service"
    ## service details
    ecs_service_name = "nginx-dummy"
    # Global Task-Definition specs
    service_specs = {
      cpu = 256
      memory = 512
    }
    # Container Specs
    task_specs = {
      cpu = 128
      image = "662716712905.dkr.ecr.eu-west-1.amazonaws.com/nginx:latest"
      memory = 128
    }
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
        match_prefix = "/dummy"
        virtual_gateway_name = module.ecs-gateway.service_name
      }
    }
}

module "ecs-nextcloud" {
    source = "./modules/ecs-service"
    ## service details
    ecs_service_name = "nextcloud"
    service_specs = {
      cpu = 1024
      memory = 2048
    }
    task_specs = {
      cpu = 512
      image = "662716712905.dkr.ecr.eu-west-1.amazonaws.com/nextcloud:latest"
      memory = 512
    }
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
    ## task envs
    environment_variables = [ {
      name = "NEXTCLOUD_TRUSTED_DOMAINS"
      value = module.apigw.apigw_domain
    },
    # {
    #     name = "APACHE_DISABLE_REWRITE_IP"
    #     value = 1
    # },{
    #     name = "TRUSTED_PROXIES"
    #     value = "10.10.0.0/16"
    # },
    {
        name = "OVERWRITEHOST"
        value = module.apigw.apigw_domain
    },
    {
        name = "OVERWRITEPROTOCOL"
        value = "https"
    },{
        name = "OVERWRITECLIURL"
        value = "https://${module.apigw.apigw_domain}"
    }
    ]
    gw_routes = {
      "nextcloud" = {
        match_prefix = "/"
        virtual_gateway_name = module.ecs-gateway.service_name
      }
      
    }
}

module "db-nextcloud" {
    source = "./modules/mysql"
    vpc_id = module.vpc.vpc_id
    db_subnet_group_name = module.vpc.database_subnet_group_name
}

