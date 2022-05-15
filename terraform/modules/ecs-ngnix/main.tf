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
                    "containerPort": 80
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

resource "aws_ecs_service" "ngnix" {
    name = local.service_name
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
        container_name = local.service_name
        container_port = 80

        
    }
}
