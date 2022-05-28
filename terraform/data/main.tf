terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.14"
        }
    }
    backend "s3" {
        bucket = "privatier-tf-state-backend"
        key = "data"
        profile = "privatier"
        region = "eu-west-1"
    }
}



module "db-nextcloud" {
    source = "./modules/rds"
    db_name = "nextcloud"
    vpc_id = module.vpc.vpc_id
    db_subnet_group_name = module.vpc.database_subnet_group_name
  
}