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
    
  
}