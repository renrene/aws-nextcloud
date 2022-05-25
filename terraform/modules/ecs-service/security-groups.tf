resource "aws_security_group" "ecs" {
    name = "sgr-${var.ecs_service_name}"
    vpc_id = var.vpc_id
    ingress  {
      cidr_blocks = [ "10.10.0.0/16" ]
      description = "access from VPC"
      from_port = 80
      to_port = 80
      protocol = "tcp"
      self = true
    } 

    ingress  {
      cidr_blocks = [ "10.10.0.0/16" ]
      description = "access from VPC"
      from_port = 22
      to_port = 22
      protocol = "tcp"
      self = true
    } 

    egress {
      cidr_blocks = [ "0.0.0.0/0" ]
      description = "world access"
      from_port = 0
      to_port = 0
      protocol = "-1"
    }
  
}