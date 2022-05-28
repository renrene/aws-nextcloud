#### Task Execution Role

data "aws_iam_policy_document" "assume_role_policy" {
    statement {
      effect = "Allow"
      actions = ["sts:AssumeRole"]
      principals {
          type = "Service"
          identifiers = [
              "ecs-tasks.amazonaws.com"
          ]
      }
    }
}

data "aws_iam_policy_document" "ecs_logs_policy" {
    statement {
        sid = "CreateCloudWatchLogStreamsAndPutLogEvents"
        actions = [ 
            "logs:CreateLogStream",
            "logs:PutLogEvents"
        ]
        effect = "Allow"
        resources = [ "${aws_cloudwatch_log_group.ecs-service.arn}:*" ]
    }
}

data "aws_iam_policy_document" "ecs_pull_from_ecr_policy" {
    statement {
        sid = "GetContainerImage"
        actions = [ 
            "ecr:GetAuthorizationToken",
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
      ]
      effect    = "Allow"
      resources = ["*"]
      
    }
}

resource "aws_iam_role" "ecs_task_execution_role" {
    name = "role-ecs-task-exec-${var.ecs_service_name}"
    assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_policy" "ecs_task_execution_logs" {
    name = "policy-ecs-allow-logs-${var.ecs_service_name}"
    description = "Allow ECS tasks to create log groups in CloudWatch and write to them"
    policy = data.aws_iam_policy_document.ecs_logs_policy.json
}

resource "aws_iam_policy" "ecs_task_execution_ecr" {
    name = "policy-ecs-allow-ecr-${var.ecs_service_name}"
    description = "Allow ECS tasks to pull images from ECR"
    policy = data.aws_iam_policy_document.ecs_pull_from_ecr_policy.json
}


resource "aws_iam_role_policy_attachment" "ecs_task_execution_logs" {
    role = aws_iam_role.ecs_task_execution_role.name
    policy_arn = aws_iam_policy.ecs_task_execution_logs.arn
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_ecr" {
    role = aws_iam_role.ecs_task_execution_role.name
    policy_arn = aws_iam_policy.ecs_task_execution_ecr.arn
}


#### Task Role

data "aws_iam_policy_document" "ecs_task_app_mesh" {
    statement {
      effect = "Allow"
      actions = [ 
          "appmesh:StreamAggregatedResources",
          "appmesh:DescribeMesh",
        ]
      resources = [ 
          "${var.app_mesh_arn}/*"
        ]
    }

}

resource "aws_iam_policy" "ecs_task_app_mesh" {
    name = "policy-ecs-task-app-mesh-${var.ecs_service_name}"
    description = "Allow ECS tasks to access the shared app-mesh"
    policy = data.aws_iam_policy_document.ecs_task_app_mesh.json
    
}

resource "aws_iam_role" "ecs_task_role" {
    assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
    name = "role-ecs-task-${var.ecs_service_name}"
    description = "IAM Role for the ECS task"  
}

resource "aws_iam_role_policy_attachment" "ecs_task_app_mesh" {
    role = aws_iam_role.ecs_task_role.name
    policy_arn = aws_iam_policy.ecs_task_app_mesh.arn
}

resource "aws_iam_role_policy_attachment" "ecs_task_logs" {
    role = aws_iam_role.ecs_task_role.name
    policy_arn = aws_iam_policy.ecs_task_execution_logs.arn
}