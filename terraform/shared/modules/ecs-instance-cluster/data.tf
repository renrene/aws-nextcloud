data "aws_vpc" "shared" {
    id = var.vpc_id
}

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

data "aws_ami" "latest-ecs-optimized" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-*"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_key_pair" "main" {
    key_name = var.key_pair_name
}

data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy" "ec2_for_ecs" {
    name = "AmazonEC2ContainerServiceforEC2Role"
}