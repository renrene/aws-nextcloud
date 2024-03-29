variable "vpc_id" {
    type = string
    description = "VPC Id of the ECS Cluster"
}

variable "cluster_id" {
    type = string
    description = "ECS Cluster id"
}

variable "cluster_type" {
    type = string
    description = "ECS Cluster type (EC2 | FARGATE)"
    default = "FARGATE"
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
