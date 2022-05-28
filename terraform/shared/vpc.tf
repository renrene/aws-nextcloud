module "vpc" {
    source = "terraform-aws-modules/vpc/aws"
    version = "3.14.0"

    name = "shared"
    cidr = "10.14.0.0/16"
    
    azs = ["${local.region}a", "${local.region}b"]
    private_subnets = ["10.14.1.0/24","10.14.2.0/24"]
    public_subnets = ["10.14.101.0/24","10.14.102.0/24"]
    database_subnets = ["10.14.201.0/24","10.14.202.0/24"]

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