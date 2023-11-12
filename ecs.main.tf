# Define the provider for AWS
provider "aws" {
  region = "us-east-1"  
}

# Create an ECS cluster
resource "aws_ecs_cluster" "my_cluster" {
  name = "doings-ecs-cluster"  
}

# Create a task definition
resource "aws_ecs_task_definition" "my_task_definition" {
  family                  = "my-task-family-test"
  requires_compatibilities = ["FARGATE"]
  network_mode            = "awsvpc"
  cpu                     = 1024
  memory                  = 2048
  execution_role_arn      = aws_iam_role.ecs_task_execution_role.arn
  container_definitions   = <<EOF
[
  {
    "name": "doings-container",
    "image": "456618395112.dkr.ecr.us-east-1.amazonaws.com/doingsecr:V1.8",  
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

# Create a service to run the task on the cluster
resource "aws_ecs_service" "ecs_service" {
  name            = "ecs-service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.my_task_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = ["subnet-072589825475e9d2a", "subnet-0814fd4f34408b5bc", "subnet-09590d1f34a08f6f3", "subnet-0c44524b610626b5e"]  
    security_groups  = ["sg-0325c4356d2209e4a"]      
    assign_public_ip = true
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs_task_execution_role"
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

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_task_execution_role.name
}
