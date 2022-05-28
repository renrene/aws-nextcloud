locals {
  ingress_cidrs = [ for s in data.aws_subnet.allow : s.cidr_block ]
  db_sbunets_ids = [ for s in data.aws_subnet.database : s.id ]
}

resource "aws_security_group" "main" {
    name = "sgr-aurora-nextcloud"
    vpc_id = var.vpc_id
    ingress {
      cidr_blocks = local.ingress_cidrs
      description = "Access from VPC"
      from_port = 5432
      to_port = 5432
      protocol = "tcp"
      self = false
    } 
    egress {
      cidr_blocks = ["10.10.0.0/16"]
      description = "Access to VPC"
      from_port = 0
      protocol = "-1"
      self = false
      to_port = 0
    } 
  
}


resource "aws_rds_cluster" "main" {
    cluster_identifier = "aurora-nextcloud"
    engine = "aurora-postgresql"
    engine_mode = "provisioned"
    engine_version = "13.6"
    database_name = "nextcloud"
    master_username = "test"
    master_password = "admin123"

    apply_immediately = true
    storage_encrypted = true
    
    db_subnet_group_name = var.db_subnet_group_name
    vpc_security_group_ids = [ aws_security_group.main.id ]

    skip_final_snapshot = true
    
    serverlessv2_scaling_configuration {
      min_capacity = 0.5
      max_capacity = 1
    }    
  
}

resource "aws_rds_cluster_instance" "main" {
    cluster_identifier = aws_rds_cluster.main.cluster_identifier
    instance_class = "db.serverless"
    db_subnet_group_name = var.db_subnet_group_name
    engine = aws_rds_cluster.main.engine
}