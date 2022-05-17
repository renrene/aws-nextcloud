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
                    "hostPort":80,

                }
            ],
            "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-group": aws_cloudwatch_log_group.ecs-nginx.name,
                    "awslogs-region": data.aws_region.current.id,
                    "awslogs-stream-prefix": "${local.service_name}-logs"
                }
            },
            "dependsOn": [{
                "containerName": "envoy",
                "condition": "HEALTHY"
            }]
            
        },
        {
            "name": "envoy",
            "image": "840364872350.dkr.ecr.eu-west-1.amazonaws.com/aws-appmesh-envoy:v1.22.0.0-prod",
            "essential": true,
            "environment": [{
                "name": "APPMESH_RESOURCE_ARN",
                "value": "${aws_appmesh_virtual_node.main.arn}"
            }],
            "healthCheck": {
                "command": [
                    "CMD-SHELL",
                    "curl -s http://localhost:9901/server_info | grep state | grep -q LIVE"
                ],
                "startPeriod": 10,
                "interval": 5,
                "timeout": 2,
                "retries": 3
            },
            "user": "1337",
            "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-group": aws_cloudwatch_log_group.ecs-nginx.name,
                    "awslogs-region": data.aws_region.current.id,
                    "awslogs-stream-prefix": "envoy-logs"
                }
            }
        }
    ])
    proxy_configuration {
        type = "APPMESH"
        container_name = "envoy"
        properties = {
            AppPorts = 80
            EgressIgnoredIPs = "169.254.170.2,169.254.169.254"
            IgnoredUID       = 1337
            ProxyEgressPort  = 15001
            ProxyIngressPort = 15000
            EgressIgnoredPorts = 22
        }
    }
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
