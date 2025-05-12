# Generate a random password for RDS instance
resource "random_password" "rds_password" {
  length           = 16   # Specify the length of the password
  special          = true # Include special characters
  override_special = "_"
  upper            = true # Include uppercase letters
  lower            = true # Include lowercase letters
  numeric          = true # Include numbers
}

# Create a DB subnet group
resource "aws_db_subnet_group" "csye6225" {
  name       = "csye6225-subnet-group"
  subnet_ids = [for subnet in aws_subnet.private : subnet.id] # Ensure this is a list of your private subnets

  tags = {
    Name = "csye6225-db-subnet-group"
  }
}

# Security group for RDS allowing only EC2 access
resource "aws_security_group" "rds_sg" {
  name        = "csye6225-db-sg"
  description = "Allow only EC2 access to RDS"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 3306 # 3306 for MySQL/MariaDB
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.webapp_sg.id] # Only allow EC2 to access RDS
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS Instance
resource "aws_db_instance" "csye6225_rds" {
  identifier             = "csye6225"
  engine                 = "mysql"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp2"
  multi_az               = false
  db_name                = var.db_name
  username               = var.rds_username                    # Master username
  password               = random_password.rds_password.result # Use random generated password
  db_subnet_group_name   = aws_db_subnet_group.csye6225.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]       # Attach the RDS security group
  publicly_accessible    = false                                # RDS should not be publicly accessible
  skip_final_snapshot    = true                                 # Avoid taking a snapshot when deleting the instance
  apply_immediately      = true                                 # Apply changes immediately
  parameter_group_name   = aws_db_parameter_group.csye6225.name # Use the custom parameter group
  storage_encrypted      = true
  kms_key_id             = aws_kms_key.rds_key.arn


  tags = {
    Name = "csye6225-db-instance"
  }
}
