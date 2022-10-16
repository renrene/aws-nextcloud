locals {
  region = data.aws_region.current.id
}

terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.14"
        }
    }
    backend "s3" {
        bucket = "nextcloud-tf-state-backend"
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
    instance_class = "db.t3.micro"
  
}


resource "aws_service_discovery_service" "db-nextcloud" {
  name = "db-nextcloud"

  dns_config {
    namespace_id = data.terraform_remote_state.shared.outputs.namespace.id

    dns_records {
      ttl  = 15
      type = "CNAME"
    }

    routing_policy = "WEIGHTED"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_instance" "db-nextcloud" {
    instance_id = "db-nextcloud"
    service_id = aws_service_discovery_service.db-nextcloud.id

    attributes = {
        AWS_INSTANCE_CNAME = split(":",module.db-nextcloud.rds_instance.endpoint)[0]
        AWS_INSTANCE_PORT = split(":",module.db-nextcloud.rds_instance.endpoint)[1]
    }
  
}

resource "aws_appmesh_virtual_node" "db-nextcloud" {
  name = "vn-db-nextcloud"
  mesh_name = data.terraform_remote_state.shared.outputs.appmesh.name

  spec {
    listener {
      port_mapping {
        port = 5432
        protocol = "tcp"
      }
    }

    service_discovery {
      aws_cloud_map {
        service_name = aws_service_discovery_service.db-nextcloud.name
        namespace_name = data.terraform_remote_state.shared.outputs.namespace.name
      }
    }
  }
}

resource "aws_appmesh_virtual_service" "db-nextcloud" {
  name = "db-nextcloud.${data.terraform_remote_state.shared.outputs.namespace.name}"
  mesh_name = data.terraform_remote_state.shared.outputs.appmesh.name

  spec {
    provider {
      virtual_node {
        virtual_node_name = aws_appmesh_virtual_node.db-nextcloud.name
      }
    }
  }
}