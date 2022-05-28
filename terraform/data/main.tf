terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.14"
        }
    }
}

module "db-nextcloud" {
    source = "./modules/rds"
  
}