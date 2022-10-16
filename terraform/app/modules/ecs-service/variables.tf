variable "ecs_cluster_id" {
    type = string
    description = "Service hosting ECS cluster id"
}

variable "ecs_cluster_type" {
    type = string
    description = "ECS Cluster type (EC2 | FARGATE)"
    default = "FARGATE"
}

variable "ecs_service_name" {
    type = string
    description = "Name of the ecs service"
}

variable "service_specs" {
    type = object(
        {
            cpu = number
            memory = number
        }
    )
    description = "cpu, memory"
}

variable "vpc_id" {
    type = string
    description = "VPC Id of the ECS Cluster"
}

variable "shared_security_id" {
    type = string
    description = "Access from shared vpc"
}

variable "service_registry_arn" {
    type = string
    description = "ARN of the CloudMap private registry"
  
}

variable "service_registry_id" {
    type = string
    description = "ID of the CloudMap private registry"
}

variable "namespace_name" {
    type = string
    description = "CloudMap namespace name"
}

variable "app_mesh_name" {
    type = string
    description = "Shared App-Mesh name"
}

variable "app_mesh_arn" {
    type = string
    description = "Shared App-Mesh arn"
  
}

variable "task_specs" {
    type = object(
        {
            cpu = number
            memory = number
            image = string
        }
    )
    description = "cpu, memory, image"
}

variable "environment_variables" {
    type = list(object(
        {
            name = string
            value = string
        }
    ))
    default = []
}

variable "gw_routes" {
    type = map(object(
        {
            virtual_gateway_name = string
            match_prefix = string
        }
    ))
    default = {}
}
