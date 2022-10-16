resource "aws_security_group" "ecs-cluster" {
    name = "sgr-${var.cluster_name}"
    vpc_id = var.vpc_id
    ingress  {
      cidr_blocks = [ data.aws_vpc.shared.cidr_block ]
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

resource "aws_iam_role" "ecs_instance_role" {
  name               = "ecs_instance_role"
  assume_role_policy = data.aws_iam_policy_document.instance-assume-role-policy.json
}

resource "aws_iam_role_policy_attachment" "ec2_for_ecs" {
    role = aws_iam_role.ecs_instance_role.name
    policy_arn = data.aws_iam_policy.ec2_for_ecs.arn
}

resource "aws_iam_instance_profile" "ecs_instance_role" {
    name = "ecs_instance_role"
    role = aws_iam_role.ecs_instance_role.name
}

resource "aws_launch_template" "main" {
    name = "launch-template-${var.cluster_name}"
    image_id = data.aws_ami.latest-ecs-optimized.id
    instance_type = var.instance_type
    key_name = data.aws_key_pair.main.key_name
    vpc_security_group_ids = [ aws_security_group.ecs-cluster.id ]
    iam_instance_profile {
        arn = aws_iam_instance_profile.ecs_instance_role.arn
    }
    private_dns_name_options {
      enable_resource_name_dns_a_record = false
    }
    user_data = base64encode("#!/bin/bash\ncat <<'EOF' >> /etc/ecs/ecs.config\nECS_CLUSTER=${var.cluster_name}\nECS_CONTAINER_INSTANCE_TAGS={\"name\": \"i-ecs-cluster-${var.cluster_name}\"}\nEOF")
}


resource "aws_autoscaling_group" "ecs-cluster" {
    name                      = "asg-ecs-cluster-${var.cluster_name}"
    vpc_zone_identifier       = [ for id in data.aws_subnets.public_subnets.ids : id]
    launch_template {
      id = aws_launch_template.main.id
    }
    desired_capacity          = var.desired_capacity
    min_size                  = var.min_capacity
    max_size                  = var.max_capacity
    health_check_grace_period = 300
    health_check_type         = "EC2"
}

resource "aws_ecs_account_setting_default" "main" {
    name = "awsvpcTrunking"
    value = "enabled"
  
}


resource "aws_ecs_cluster" "main" {
    name = var.cluster_name
}