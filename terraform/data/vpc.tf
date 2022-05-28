module "vpc" {
    source = "terraform-aws-modules/vpc/aws"
    version = "3.14.0"

    name = "data"
    cidr = "10.12.0.0/16"
    
    azs = ["${local.region}a", "${local.region}b"]
    private_subnets = ["10.12.1.0/24","10.12.2.0/24"]
    public_subnets = ["10.12.101.0/24","10.12.102.0/24"]
    database_subnets = ["10.12.201.0/24","10.12.202.0/24"]

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

    database_subnet_tags = {
      "type" = "database"
    }
    manage_default_security_group = false
}