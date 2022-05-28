locals {
  
}


resource "aws_security_group" "main" {
    name = "sgr-rds-${var.db_name}"
    vpc_id = var.vpc_id
    ingress {
      cidr_blocks = [ data.aws_vpc.data.cidr_block ]
      description = "Access from VPC"
      from_port = 5432
      to_port = 5432
      protocol = "tcp"
      self = false
    } 
    egress {
      cidr_blocks = [ data.aws_vpc.data.cidr_block ]
      description = "Access to VPC"
      from_port = 0
      protocol = "-1"
      self = false
      to_port = 0
    } 
  
}

resource "random_password" "admin_password" {
    length = 16
    special = true
}

resource "aws_ssm_parameter" "admin_password" {
    name = "/infra/rds-${var.db_name}/admin-password"
    type = "SecureString"
    value = random_password.admin_password.result
}

resource "aws_ssm_parameter" "admin_username" {
    name = "/infra/rds-${var.db_name}/admin-username"
    type = "String"
    value = "dbadmin"
}

resource "aws_db_instance" "main" {
    identifier = "rds-postgres-${var.db_name}" 
    engine = "postgres"
    engine_version = "13.6"   
    allocated_storage = 5
    max_allocated_storage = 10
    copy_tags_to_snapshot = true
    db_subnet_group_name = var.db_subnet_group_name
    db_name = var.db_name
    username = aws_ssm_parameter.admin_username.value
    password = aws_ssm_parameter.admin_password.value
    skip_final_snapshot = true
    # final_snapshot_identifier = "final-snap-${var.db_name}"
    instance_class = var.instance_class
    vpc_security_group_ids = [ aws_security_group.main.id ]
}
