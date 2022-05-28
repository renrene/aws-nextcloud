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

resource "aws_db_instance" "main" {
    identifier = "rds-postgres-${var.db_name}" 
    engine = "PostgreSQL"
    engine_version = "13.6"   
    allocated_storage = 20
    max_allocated_storage = 40
    copy_tags_to_snapshot = true
    db_subnet_group_name = var.db_subnet_group_name
    db_name = var.db_name
    skip_final_snapshot = true
    # final_snapshot_identifier = "final-snap-${var.db_name}"
    instance_class = var.instance_class
    vpc_security_group_ids = [ aws_security_group.main.id ]
}
