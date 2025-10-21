resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "Allow HTTP access"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP inbound"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow ICMP inbound"
    from_port   = -1
    to_port     = -1
    protocol    = "ICMP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow * outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_lb" "main" {
  name               = "notes-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids

  tags = {
    Name = "notes-alb"
  }
}

resource "aws_lb_target_group" "frontend" {
  name        = "notes-frontend-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  #   health_check {
  #     enabled             = true
  #     healthy_threshold   = 2
  #     interval            = 30
  #     matcher             = "200"
  #     path                = "/"
  #     port                = "traffic-port"
  #     protocol            = "HTTP"
  #     timeout             = 5
  #     unhealthy_threshold = 2
  #   }

  tags = {
    Name = "notes-frontend-tg"
  }
}

resource "aws_lb_target_group" "backend" {
  name        = "notes-backend-tg"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
    enabled             = true
    interval            = 30
    healthy_threshold   = 3
    timeout             = 5
    unhealthy_threshold = 3
  }

  tags = {
    Name = "notes-backend-tg"
  }
}

# ALB Listeners
resource "aws_lb_listener" "frontend" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

resource "aws_lb_listener_rule" "backend" {
  listener_arn = aws_lb_listener.frontend.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }

  condition {
    path_pattern {
      values = ["/notes/*"]
    }
  }
}


output "frontend_tg_arn" {
  value = aws_lb_target_group.frontend.arn
}

output "backend_tg_arn" {
  value = aws_lb_target_group.backend.arn
}

output "alb_url" {
  value = aws_lb.main.dns_name
}

output "sg_id" {
  value = aws_security_group.alb_sg.id
}
