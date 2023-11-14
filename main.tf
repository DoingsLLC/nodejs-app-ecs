provider "aws" {
  region = "us-east-1"  # Adjust the region as needed
}

resource "aws_ecs_cluster" "my_cluster" {
  name = "default-ecs-cluster"
}

resource "aws_ecs_task_definition" "my_task_definition" {
  family                  = "my-task-family"
  requires_compatibilities = ["FARGATE"]
  network_mode            = "awsvpc"
  cpu                     = 256
  memory                  = 512

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = <<EOF
[
  {
    "name": "my-container",
    "image": "nginx:latest",
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      }
    ]
  }
]
EOF
}

resource "aws_ecs_service" "ecs_service" {
  name            = "default-ecs-service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.my_task_definition.arn
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = ["subnet-0aa0739f3f084ad3e"]  # Adjust the subnet as needed
    assign_public_ip = true
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "default-ecs-task-execution-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
