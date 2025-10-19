resource "aws_ecs_cluster" "notes-cluster" {
  name = "notes-containers-cluster"
}


resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}



resource "aws_ecs_task_definition" "backend" {
  family                   = "notes-backend"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      "name"      = "notes-backend",
      "image"     = "${var.ecr_repo_urls.backend}:latest",
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

resource "aws_ecs_task_definition" "frontend" {
  family                   = "notes-frontend"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      "name"      = "notes-frontend",
      "image"     = "${var.ecr_repo_urls.frontend}:latest",
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
    }
  ])
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

resource "aws_security_group" "frontend" {
  name        = "frontend-sg"
  description = "Allow ALB to reach frontend containers"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow HTTP traffic from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = var.alb_sg_ids
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "frontend-sg"
  }
}


resource "aws_security_group" "backend" {
  name        = "backend-sg"
  description = "Allow ALB to reach frontend containers"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow HTTP traffic from ALB"
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = var.alb_sg_ids
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "frontend-sg"
  }
}


resource "aws_ecs_service" "notes-frontend" {
  name            = "notes-frontend"
  cluster         = aws_ecs_cluster.notes-cluster.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.frontend.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.alb_tg_frontend_arn
    container_name   = "notes-frontend"
    container_port   = 80
  }

  tags = {
    Name = "notes-frontend-service"
  }
}

resource "aws_ecs_service" "backend" {
  name            = "notes-backend"
  cluster         = aws_ecs_cluster.notes-cluster.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.backend.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.alb_tg_backend_arn
    container_name   = "notes-backend"
    container_port   = 8000
  }

  tags = {
    Name = "notes-backend-service"
  }
}

output "cluster_name" {
  value = aws_ecs_cluster.notes-cluster.name
}
