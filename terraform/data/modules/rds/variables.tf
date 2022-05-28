variable "vpc_id" {
    type = string
}

variable "db_subnet_group_name" {
    type = string
}

variable "db_name" {
    type = string
    description = "name for the rds instance and the database itself"
}

variable "instance_class" {
    type = string
    description = "AWS instance class for this rds instance"
}