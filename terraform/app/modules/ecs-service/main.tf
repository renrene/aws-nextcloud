locals {
    main_task = {
            name = var.ecs_service_name
            image = var.task_specs.image
            cpu = var.task_specs.cpu
            memory = var.task_specs.memory
            essential = true
            environment = var.environment_variables
            portMappings =  [
                {
                    protocol = "tcp"
                    containerPort = 80
                },
                {
                    protocol = "tcp"
                    containerPort = 22
                }
            ]
            logConfiguration = {
                logDriver = "awslogs"
                options = {
                    awslogs-group = aws_cloudwatch_log_group.ecs-service.name
                    awslogs-region = data.aws_region.current.id
                    awslogs-stream-prefix = "${var.ecs_service_name}-logs"
                }
            }
            dependsOn = [{
                containerName = "envoy"
                condition = "HEALTHY"
            }]
            
        }
    
    envoy_task = {        
            name = "envoy"
            image = "840364872350.dkr.ecr.eu-west-1.amazonaws.com/aws-appmesh-envoy:v1.22.0.0-prod"
            essential = true
            environment = [{
                name = "APPMESH_RESOURCE_ARN",
                value = aws_appmesh_virtual_node.main.arn
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
            user = "1337"
            logConfiguration = {
                logDriver = "awslogs"
                options = {
                    awslogs-group = aws_cloudwatch_log_group.ecs-service.name
                    awslogs-region = data.aws_region.current.id
                    awslogs-stream-prefix = "envoy-logs"
                }
            }
        }
    
}


resource "aws_cloudwatch_log_group" "ecs-service" {
    name = "log-group-${var.ecs_service_name}"
    retention_in_days = 7
}

resource "aws_ecs_task_definition" "main" {
    family = var.ecs_service_name
    network_mode = "awsvpc"
    cpu = var.service_specs.cpu
    memory = var.service_specs.memory
    requires_compatibilities = [ "FARGATE" ]
    execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
    task_role_arn = aws_iam_role.ecs_task_role.arn
    container_definitions = jsonencode([
        local.main_task,
        local.envoy_task
    ])
    proxy_configuration {
        type = "APPMESH"
        container_name = "envoy"
        properties = {
            AppPorts = "80,443"
            EgressIgnoredIPs = "169.254.170.2,169.254.169.254"
            IgnoredUID       = 1337
            ProxyEgressPort  = 15001
            ProxyIngressPort = 15000
            EgressIgnoredPorts = 22
        }
    }
}

resource "aws_ecs_service" "main" {
    name = var.ecs_service_name
    cluster = var.ecs_cluster_id
    task_definition = aws_ecs_task_definition.main.arn
    launch_type = "FARGATE"
    desired_count = 1

    network_configuration {
        security_groups = [ aws_security_group.ecs.id ]
        subnets = data.aws_subnets.public_subnets.ids
        assign_public_ip = true
    }

    service_registries {
        registry_arn = aws_service_discovery_service.main.arn
        container_name = var.ecs_service_name
        container_port = 80
    }
}
