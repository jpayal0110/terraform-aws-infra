resource "aws_lb" "web_app_alb" {
  name               = "web-app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id] # Use the security group from security-group.tf
  subnets            = aws_subnet.public[*].id

  enable_deletion_protection = false

  tags = {
    Name = "WebAppALB"
  }
}

# Target Group for Web App
resource "aws_lb_target_group" "webapp_tg" {
  name        = "webapp-tg"
  port        = 8080 # Change if your application runs on a different port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance" # We are using EC2 instances as targets

  health_check {
    path                = "/healthz" # Update to your app’s health check endpoint if different
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    protocol            = "HTTP"
  }

  tags = {
    Name = "WebAppTargetGroup"
  }
}

# ALB Listener - HTTP (Port 80)
resource "aws_lb_listener" "http_listener" {
  depends_on        = [aws_lb_target_group.webapp_tg]
  load_balancer_arn = aws_lb.web_app_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.webapp_acm_cert_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webapp_tg.arn
  }
}
