terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.14"
        }
    }
}

locals {
    region = data.aws_region.current.id
}
