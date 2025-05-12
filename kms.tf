data "aws_caller_identity" "current" {}

resource "aws_kms_key" "ec2_key" {
  description             = "KMS key for EC2"
  enable_key_rotation     = true
  deletion_window_in_days = 7
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "key-default-1"
    Statement = [
      {
        "Sid" : "Allow attachment of persistent resources",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
          ]
        },
        "Action" : [
          "kms:CreateGrant"
        ],
        "Resource" : "*",
        "Condition" : {
          "Bool" : {
            "kms:GrantIsForAWSResource" : true
          }
        }
      },
      {
        "Sid" : "Allow service-linked role use of the customer managed key",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
          ]
        },
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        "Resource" : "*"
      },
      { Sid       = "Allow administration of the key"
        Effect    = "Allow"
        Principal = { AWS = data.aws_caller_identity.current.arn },
        Action = ["kms:ReplicateKey",
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:ScheduleKeyDeletion",
        "kms:CancelKeyDeletion"],
      Resource = "*" },
      {
        "Sid" : "Enable IAM User Permissions",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        "Action" : "kms:DescribeKey",
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_kms_key" "rds_key" {
  description             = "KMS key for RDS"
  enable_key_rotation     = true
  deletion_window_in_days = 7
}

resource "aws_kms_key" "s3_key" {
  description             = "KMS key for S3 Bucket"
  enable_key_rotation     = true
  deletion_window_in_days = 7
}

resource "aws_kms_key" "secrets_key" {
  description             = "KMS key for Secrets Manager Encryption"
  enable_key_rotation     = true
  deletion_window_in_days = 7
}

resource "aws_kms_alias" "secrets_key_alias" {
  name          = "alias/secrets-key"
  target_key_id = aws_kms_key.secrets_key.id
}
