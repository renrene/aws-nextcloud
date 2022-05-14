data "aws_subnets" "private_subnets" {
    filter {
      name = "vpc-id"
      values = [ var.vpc_id ]
    }   

    filter {
      name = "tag:type"
      values = [ "private" ]
    }
}