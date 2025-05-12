# Launch Template for EC2 instances in Auto Scaling Group
resource "aws_launch_template" "web_app_lt" {
  name_prefix   = "webapp-lt"
  image_id      = var.ami_id
  instance_type = "t2.micro"
  key_name      = var.key_name

  network_interfaces {
    security_groups             = [aws_security_group.webapp_sg.id]
    associate_public_ip_address = true
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.aws_profile.name
  }

  monitoring {
    enabled = true
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 8
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
      kms_key_id            = aws_kms_key.ec2_key.arn
    }
  }


  user_data = base64encode(templatefile("${path.module}/user-data.sh", {
    DB_HOST        = aws_db_instance.csye6225_rds.address
    DB_NAME        = var.db_name
    DB_USER        = var.rds_username
    SECRET_ID      = aws_secretsmanager_secret.rds_password_secret.id
    AWS_REGION     = var.aws_region
    S3_BUCKET_NAME = aws_s3_bucket.webapp_bucket.bucket
  }))
}

# Auto Scaling Group
resource "aws_autoscaling_group" "webapp_asg" {
  name                = "webapp-asg"
  desired_capacity    = 4
  min_size            = 3
  max_size            = 5
  vpc_zone_identifier = aws_subnet.public[*].id # Public subnets

  launch_template {
    id      = aws_launch_template.web_app_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "WebAppAutoScalingInstance"
    propagate_at_launch = true
  }
}

# Scaling Policy - Scale Up
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale-up-policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.webapp_asg.name
}

# Scaling Policy - Scale Down
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scale-down-policy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.webapp_asg.name
}

resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.webapp_asg.id
  lb_target_group_arn    = aws_lb_target_group.webapp_tg.arn
}
