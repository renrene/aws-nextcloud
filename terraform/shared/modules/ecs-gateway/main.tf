locals {
    service_name = "vg-main"
    envoy_task = {        
            name = "envoy"
            image = "840364872350.dkr.ecr.eu-west-1.amazonaws.com/aws-appmesh-envoy:v1.22.0.0-prod"
            essential = true
            environment = [{
                name = "APPMESH_RESOURCE_ARN",
                value = aws_appmesh_virtual_gateway.main.arn
            }]
            healthCheck = {
                command = [
                    "CMD-SHELL",
                    "curl -s http://localhost:9901/server_info | grep state | grep -q LIVE"
                ]
                startPeriod = 10
                interval = 5
                timeout = 2
                retries = 3
            }
            logConfiguration = {
                logDriver = "awslogs"
                options = {
                    awslogs-group = aws_cloudwatch_log_group.ecs-service.name
                    awslogs-region = data.aws_region.current.id
                    awslogs-stream-prefix = "envoy-logs"
                }
            }
            portMappings = [{
                containerPort = 80
            }]
    }
    
}

resource "aws_cloudwatch_log_group" "ecs-service" {
    name = "log-group-${local.service_name}"
    retention_in_days = 7
}


resource "aws_ecs_task_definition" "main" {
    family = local.service_name
    network_mode = "awsvpc"
    cpu = 128
    memory = 128
    requires_compatibilities = [ var.cluster_type ]
    execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
    task_role_arn = aws_iam_role.ecs_task_role.arn
    container_definitions = jsonencode([
        local.envoy_task
    ])
}

resource "aws_ecs_service" "main" {
    name = local.service_name
    cluster = var.cluster_id
    task_definition = aws_ecs_task_definition.main.arn
    launch_type = var.cluster_type
    desired_count = 1

    network_configuration {
        security_groups = [ aws_security_group.ecs.id ]
        subnets = data.aws_subnets.public_subnets.ids
    }

    service_registries {
        registry_arn = aws_service_discovery_service.main.arn
        port = 80
    }
}
