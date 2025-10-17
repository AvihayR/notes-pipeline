resource "aws_ecs_cluster" "notes-cluster" {
  name = "notes-containers-cluster"
}

resource "aws_ecs_task_definition" "notes-app-task" {
  family = "notes-tasks"
  container_definitions = jsonencode([
    {
      "name"      = "notes-frontend",
      "image"     = "${var.repo_url}/notes-frontend:latest",
      "cpu"       = 256,
      "memory"    = 512,
      "essential" = true,
      "portMappings" = [
        {
          "containerPort" = 80,
          "hostPort"      = 80,
          "protocol"      = "tcp"
        }
      ],
      "environment" = [
        {
          "name"  = "API_URL"
          "value" = var.backend_url
        }
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.frontend.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "frontend"
        }
      }
    },
    {
      "name"      = "notes-backend",
      "image"     = "${var.repo_url}/notes-backend:latest",
      "cpu"       = 256,
      "memory"    = 512,
      "essential" = true,
      "portMappings" = [
        {
          "containerPort" = 8000,
          "hostPort"      = 8000,
          "protocol"      = "tcp"
        }
      ],
      "environment" = [
        {
          "name"  = "MONGODB_URL"
          "value" = var.db_url
        }
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.backend.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "backend"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "notes-service" {
  name            = "notes-app-service"
  cluster         = aws_ecs_cluster.notes-cluster.id
  task_definition = aws_ecs_task_definition.notes-app-task.arn
  desired_count   = 2
}

resource "aws_cloudwatch_log_group" "backend" {
  name              = "/ecs/backend"
  retention_in_days = 7

  tags = {
    Name = "backend-logs"
  }
}

resource "aws_cloudwatch_log_group" "frontend" {
  name              = "/ecs/frontend"
  retention_in_days = 7

  tags = {
    Name = "frontend-logs"
  }
}

output "name" {
  value = aws_ecs_cluster.notes-cluster.name
}
