locals {
    service_name = "nginx-dummy"
}

resource "aws_cloudwatch_log_group" "ecs-nginx" {
    name = "log-group-${local.service_name}"
    retention_in_days = 7
}

resource "aws_ecs_cluster" "main" {
    name = "main"
}

resource "aws_ecs_task_definition" "ngnix" {
    family = local.service_name
    network_mode = "awsvpc"
    cpu = 512
    memory = 1024
    requires_compatibilities = [ "FARGATE" ]
    execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
    container_definitions = jsonencode([
        {
            "name": local.service_name,
            "image": "662716712905.dkr.ecr.eu-west-1.amazonaws.com/nginx:latest",
            "cpu": 128,
            "memory": 128,
            "essential": true,
            "portMappings": [
                {
                    "containerPort": 80,
                    "hostPort": 80
                }
            ],
            "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-group": aws_cloudwatch_log_group.ecs-nginx.name,
                    "awslogs-region": data.aws_region.current.id,
                    "awslogs-stream-prefix": "${local.service_name}-logs"
                }
            }
            
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

    service_registries {
        registry_arn = aws_service_discovery_service.main.arn
    }
}
