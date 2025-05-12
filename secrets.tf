resource "aws_secretsmanager_secret" "rds_password_secret" {
  name                    = "rds-password"
  description             = "Password for RDS database"
  kms_key_id              = aws_kms_key.secrets_key.arn
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "rds_password_version" {
  secret_id     = aws_secretsmanager_secret.rds_password_secret.id
  secret_string = random_password.rds_password.result
}
