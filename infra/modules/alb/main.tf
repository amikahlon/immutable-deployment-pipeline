# -----------------------------
# Application Load Balancer
# -----------------------------
resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids

  tags = {
    Name = "${var.project_name}-alb"
  }
}

# -----------------------------
# Target Group - Client (port 3000)
# -----------------------------
resource "aws_lb_target_group" "client" {
  name     = "${var.project_name}-tg-client"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name = "${var.project_name}-tg-client"
  }
}

# -----------------------------
# Target Group - Server (port 4000)
# -----------------------------
resource "aws_lb_target_group" "server" {
  name     = "${var.project_name}-tg-server"
  port     = 4000
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200,404"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name = "${var.project_name}-tg-server"
  }
}

# -----------------------------
# Listener - HTTP :80
# Default → client
# -----------------------------
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.client.arn
  }
}

# -----------------------------
# Listener Rule - /api/* → server
# -----------------------------
# -----------------------------
# SSM Parameter — ALB DNS
# Used by CI to build the client image with the correct API base URL
# -----------------------------
resource "aws_ssm_parameter" "alb_dns" {
  name  = "/${var.project_name}/alb-dns"
  type  = "String"
  value = aws_lb.main.dns_name

  tags = {
    Name = "${var.project_name}-alb-dns"
  }
}

resource "aws_lb_listener_rule" "api" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  condition {
    path_pattern {
      values = ["/api", "/api/*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.server.arn
  }
}
