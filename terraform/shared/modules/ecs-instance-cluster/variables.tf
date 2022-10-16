variable "vpc_id" {
    type = string
    description = "VPC Id of the ECS Cluster"
}

variable "cluster_name" {
    type = string
    description = "A name for the ECS cluster"
}

variable "key_pair_name" {
    type = string
    description = "key pair name to find and use in ec2 launch config"
}

variable "instance_type" {
    type = string
    description = "EC2 instance type to use in ec2 launch config"
}

variable "desired_capacity" {
    type = number
    description = "desired number of ec2 instances in the ecs cluster"
}

variable "min_capacity" {
    type = number
    description = "minimum number of ec2 instances in the ecs cluster"
}

variable "max_capacity" {
    type = number
    description = "maximum number of ec2 instances in the ecs cluster"
}