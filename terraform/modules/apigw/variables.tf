variable "vpc_link_subnets" {
    type = list(string)
    description = "list of vpc subnets to integate the api with"
}

variable "vpc_link_security_groups" {
    type = list(string)
    description = "list of vpc security groups to integate the api with" 
}

variable "public_hosted_zone" {
    type = string
    description = "Route53 public hosted zone for the api dns record and ssl cert."
}

variable "service_name" {
    type = string
    description = "fqdn and discoverable service name"
}