data "aws_subnets" "public_subnets" {
    filter {
      name = "vpc-id"
      values = [ var.vpc_id ]
    }   

    filter {
      name = "tag:type"
      values = [ "public" ]
    }
}