module "vpc" {
    source = "terraform-aws-modules/vpc/aws"
    version = "3.14.0"

    name = "main"
    cidr = "10.10.0.0/16"
    
    azs = ["${local.region}a", "${local.region}b"]
    private_subnets = ["10.10.1.0/24","10.10.2.0/24"]
    public_subnets = ["10.10.101.0/24","10.10.102.0/24"]

    enable_ipv6 = false
    enable_nat_gateway = false
    
    tags = {
      "managed_by" = "terraform"
      "environment" = "prod"
    }

    private_subnet_tags = {
        "type" = "private"
    }

    public_subnet_tags = {
        "type" = "public"
    }
    manage_default_security_group = false
}


locals {
    region = data.aws_region.current.id
}