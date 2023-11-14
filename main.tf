provider "aws" {
  region = "us-east-1"
}

resource "aws_ecs_cluster" "doings_cluster" {
  name = "doings-ecs-cluster"
}

resource "aws_ecs_task_definition" "doings_task" {
  family                   = "doings-task" 
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = <<DEFINITION
[
  {
    "name": "doings-container",
    "image": "doingsllc/nodejs-app:V10.01",
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80 
      }
    ]
  }
]
DEFINITION

}

resource "aws_ecs_service" "doings_service" {
  name            = "doings-service"
  cluster         = aws_ecs_cluster.doings_cluster.id
  task_definition = aws_ecs_task_definition.doings_task.arn
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = ["subnet-0aa0739f3f084ad3e"]
    assign_public_ip = true
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "doings-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com" 
        }
      },
    ]
  })
  
  inline_policy {
    name = "doings-ecs-task-permissions"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = [
            "ecr:GetAuthorizationToken",
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Effect   = "Allow"
          Resource = "*"
        },
      ]  
    })
  }
}
