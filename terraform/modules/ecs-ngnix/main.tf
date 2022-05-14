resource "aws_ecs_cluster" "main" {
    name = "main"
}

resource "aws_ecs_task_definition" "ngnix" {
    family = "ngnix"
    network_mode = "awsvpc"
    cpu = 512
    memory = 1024
    requires_compatibilities = [ "FARGATE" ]
    execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
    container_definitions = jsonencode([
        {
            name = "ngnix-dummy"
            image = "662716712905.dkr.ecr.eu-west-1.amazonaws.com/nginx:latest"
            cpu = 128
            memory = 128
            essential = true
            portMapping = [
                {
                    containerPort = 80
                }
            ]
        }
    ])
}

resource "aws_security_group" "ecs" {
    name = "main-ngnix"
    vpc_id = var.vpc_id
    ingress  {
      cidr_blocks = [ "10.10.0.0/16" ]
      description = "access from VPC"
      from_port = 80
      to_port = 80
      protocol = "tcp"
    } 
    egress {
      cidr_blocks = [ "0.0.0.0/0" ]
      description = "world access"
      from_port = 0
      to_port = 0
      protocol = "-1"
    }
  
}

resource "aws_ecs_service" "ngnix" {
    name = "ngnix"
    cluster = aws_ecs_cluster.main.id
    task_definition = aws_ecs_task_definition.ngnix.arn
    launch_type = "FARGATE"
    desired_count = 1

    network_configuration {
        security_groups = [ aws_security_group.ecs.id ]
        subnets = data.aws_subnets.public_subnets.ids
        assign_public_ip = true
    }
}
