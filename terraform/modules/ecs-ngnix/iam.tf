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
        sid = "CreateCloudWatchLogGroups"
        actions = [ 
            "logs:CreateLogGroup" 
        ]
        effect = "Allow"
        resources = ["*"]
    }
    statement {
        sid = "CreateCloudWatchLogStreamsAndPutLogEvents"
        actions = [ 
            "logs:CreateLogStream",
            "logs:PutLogEvents"
        ]
        effect = "Allow"
        resources = ["*"]
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
    name = "role-ecs-exec-tasks"
    assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_policy" "ecs_task_execution_logs" {
    name = "policy-ecs-allow-logs"
    description = "Allow ECS tasks to create log groups in CloudWatch and write to them"
    policy = data.aws_iam_policy_document.ecs_logs_policy.json
}

resource "aws_iam_policy" "ecs_task_execution_ecr" {
    name = "policy-ecs-allow-ecr"
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
