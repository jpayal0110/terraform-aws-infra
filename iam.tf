# IAM policy document for EC2 Assume Role
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# IAM Role for EC2 (Combining S3, CloudWatch, SecretsManager, and AutoScaling Permissions)
resource "aws_iam_role" "iam_role" {
  name               = "webapp-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

# IAM Policy for S3 Access
resource "aws_iam_policy" "s3_access_policy" {
  name        = "webapp-policy"
  description = "Allow EC2 to access S3 buckets and objects"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "s3:ListBucket"
        Resource = "arn:aws:s3:::*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetObjectAttributes",
          "s3:GetObjectTagging",
          "s3:DeleteObject"
        ]
        Resource = [
          aws_s3_bucket.webapp_bucket.arn,
          "${aws_s3_bucket.webapp_bucket.arn}/*"
        ]
      }
    ]
  })
}

# IAM Policy for Secrets Manager Access
resource "aws_iam_policy" "secretsmanager_read_policy" {
  name        = "SecretsManagerReadPolicy"
  description = "Allows EC2 to read secrets from AWS Secrets Manager"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue"
        ],
        Resource = aws_secretsmanager_secret.rds_password_secret.arn
      }
    ]
  })
}

resource "aws_iam_policy" "kms_ec2_policy" {
  name        = "KmsEc2Policy"
  description = "Allows EC2 to interact with kms"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:CreateGrant",
          "kms:GenerateDataKey",
        ]
        Resource = [
          aws_kms_key.s3_key.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:CreateGrant",
        ]
        Resource = [
          aws_kms_key.secrets_key.arn
        ]
      }
    ]
  })
}

# Attach Policies to IAM Role - S3, CloudWatch, SecretsManager, and KMS for AutoScaling
resource "aws_iam_role_policy_attachment" "attach_s3_policy_to_ec2" {
  role       = aws_iam_role.iam_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_cloudwatch_policy_to_ec2" {
  role       = aws_iam_role.iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "attach_secretsmanager_policy_to_ec2" {
  role       = aws_iam_role.iam_role.name
  policy_arn = aws_iam_policy.secretsmanager_read_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_kms_policy_to_ec2" {
  role       = aws_iam_role.iam_role.name
  policy_arn = aws_iam_policy.kms_ec2_policy.arn
}

# resource "aws_iam_role_policy_attachment" "attach_kms_autoscaling_policy_to_ec2" {
#   role       = aws_iam_role.iam_role.name
#   policy_arn = aws_iam_policy.kms_autoscaling_policy.arn
# }

# IAM Instance Profile (Required for EC2 to assume the role)
resource "aws_iam_instance_profile" "aws_profile" {
  name = "aws_profile"
  role = aws_iam_role.iam_role.name
}
