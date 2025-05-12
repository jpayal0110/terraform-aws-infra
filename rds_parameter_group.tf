# rds_parameter_group.tf

resource "aws_db_parameter_group" "csye6225" {
  name        = "csye6225-parameter-group"
  family      = "mysql8.0" # Specify the MySQL version family
  description = "Custom parameter group for csye6225 RDS instance"

  #   parameter {
  #     name  = "max_connections"
  #     value = "200"  # Example parameter: Adjust as needed
  #   }

  #   parameter {
  #     name  = "wait_timeout"
  #     value = "28800"  # Example timeout value: Adjust as needed
  #   }

  # Add any other parameters you need for your database engine
}
