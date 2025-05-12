resource "aws_security_group" "webapp_sg" {
  name        = "app-security-group"
  description = "Allow inbound traffic only from Load Balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    # security_groups = [aws_security_group.lb_sg.id] # Only allow from Load Balancer
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 8080 # Change this if your app runs on a different port
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg.id] # Only allow from Load Balancer
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "WebAppSG"
  }
}
resource "aws_security_group" "lb_sg" {
  name        = "load-balancer-sg"
  description = "Allow inbound traffic on ports 80 and 443"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lb_sg"
  }
}
