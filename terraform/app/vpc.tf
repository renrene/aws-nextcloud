module "vpc" {
    source = "terraform-aws-modules/vpc/aws"
    version = "3.14.0"

    name = "main"
    cidr = "10.10.0.0/16"
    
    azs = ["${local.region}a", "${local.region}b"]
    private_subnets = ["10.10.1.0/24","10.10.2.0/24"]
    public_subnets = ["10.10.101.0/24","10.10.102.0/24"]
    database_subnets = ["10.10.201.0/24","10.10.202.0/24"]

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

## Shared vpc peering, routing and security groups
resource "aws_vpc_peering_connection" "shared" {
  vpc_id = module.vpc.vpc_id
  peer_vpc_id = data.terraform_remote_state.shared.outputs.vpc.vpc_id
  auto_accept = true
}

resource "aws_route" "main-shared" {
    count = length(module.vpc.public_route_table_ids)
    route_table_id = module.vpc.public_route_table_ids[count.index]
    destination_cidr_block = data.terraform_remote_state.shared.outputs.vpc.vpc_cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.shared.id
}

resource "aws_route" "shared-main" {
    count = length(data.terraform_remote_state.shared.outputs.vpc.public_route_table_ids)
    route_table_id = data.terraform_remote_state.shared.outputs.vpc.public_route_table_ids[count.index]
    destination_cidr_block = module.vpc.vpc_cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.shared.id
}

resource "aws_security_group" "access_from_share" {
    vpc_id = module.vpc.vpc_id
    ingress {
      cidr_blocks = [ data.terraform_remote_state.shared.outputs.vpc.vpc_cidr_block ]
      description = "Access from shared VPC"
      from_port = 0
      to_port = 0
      protocol = "-1"
      self = false
    }
}


## Data vpc peering, routing and security groups
resource "aws_vpc_peering_connection" "data" {
  count = can(data.terraform_remote_state.data.outputs.vpc.vpc_id) ?  1 : 0
  vpc_id = module.vpc.vpc_id
  peer_vpc_id = data.terraform_remote_state.data.outputs.vpc.vpc_id
  auto_accept = true  
}

resource "aws_route" "main-data" {
    count = can(data.terraform_remote_state.data.outputs.vpc.vpc_id) ? length(module.vpc.public_route_table_ids) : 0
    route_table_id = module.vpc.public_route_table_ids[count.index]
    destination_cidr_block = data.terraform_remote_state.data.outputs.vpc.vpc_cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.data[0].id
}

resource "aws_route" "data-main" {
    count = can(data.terraform_remote_state.data.outputs.vpc.vpc_id) ?  length(data.terraform_remote_state.data.outputs.vpc.database_route_table_ids) : 0 
    route_table_id = data.terraform_remote_state.data.outputs.vpc.database_route_table_ids[count.index]
    destination_cidr_block = module.vpc.vpc_cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.data[0].id
}


resource "aws_security_group_rule" "access_to_data" {
  count = can(data.terraform_remote_state.data.outputs.nextcloud_db_security_group) ?  1 : 0
  type = "ingress"
  security_group_id = data.terraform_remote_state.data.outputs.nextcloud_db_security_group
  cidr_blocks = [ module.vpc.vpc_cidr_block ]
  description = "Access from apps VPC"
  from_port = 0
  to_port = 0
  protocol = "-1"
}
