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
        bucket = "nextcloud-tf-state-backend"
        key = "app"
        profile = "privatier"
        region = "eu-west-1"
    }
}

module "ecs-nginx" {
    source = "./modules/ecs-service"
    ## service details
    ecs_service_name = "nginx-dummy"
    # Global Task-Definition specs
    service_specs = {
      cpu = 128
      memory = 128
    }
    # Container Specs
    task_specs = {
      cpu = 128
      image = "662716712905.dkr.ecr.eu-west-1.amazonaws.com/nginx:latest"
      memory = 128
    }
    ## cluster and vpc
    ecs_cluster_id = data.terraform_remote_state.shared.outputs.ecs_cluster.id
    ecs_cluster_type = "EC2"
    vpc_id = module.vpc.vpc_id
    shared_security_id = aws_security_group.access_from_share.id
    ## service descovery
    service_registry_arn = data.terraform_remote_state.shared.outputs.namespace.arn
    service_registry_id = data.terraform_remote_state.shared.outputs.namespace.id
    namespace_name = data.terraform_remote_state.shared.outputs.namespace.name
    ## app mesh
    app_mesh_name = data.terraform_remote_state.shared.outputs.appmesh.name
    app_mesh_arn = data.terraform_remote_state.shared.outputs.appmesh.arn
    ## gateway routes
    gw_routes = {
      "nginx" = {
        match_prefix = "/dummy"
        virtual_gateway_name = data.terraform_remote_state.shared.outputs.gateway_service_name
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
    ecs_cluster_id = data.terraform_remote_state.shared.outputs.ecs_cluster.id
    vpc_id = module.vpc.vpc_id
    shared_security_id = aws_security_group.access_from_share.id
    ## service descovery
    service_registry_arn = data.terraform_remote_state.shared.outputs.namespace.arn
    service_registry_id = data.terraform_remote_state.shared.outputs.namespace.id
    namespace_name = data.terraform_remote_state.shared.outputs.namespace.name
    ## app mesh
    app_mesh_name = data.terraform_remote_state.shared.outputs.appmesh.name
    app_mesh_arn = data.terraform_remote_state.shared.outputs.appmesh.arn
    ## task envs
    environment_variables = [ {
      name = "NEXTCLOUD_TRUSTED_DOMAINS"
      value = data.terraform_remote_state.shared.outputs.apigw_domain_name
    },
    {
        name = "OVERWRITEHOST"
        value = data.terraform_remote_state.shared.outputs.apigw_domain_name
    },
    {
        name = "OVERWRITEPROTOCOL"
        value = "https"
    },{
        name = "OVERWRITECLIURL"
        value = "https://${data.terraform_remote_state.shared.outputs.apigw_domain_name}"
    }
    ]
    gw_routes = {
      "nextcloud" = {
        match_prefix = "/"
        virtual_gateway_name = data.terraform_remote_state.shared.outputs.gateway_service_name
      }
      
    }
}
