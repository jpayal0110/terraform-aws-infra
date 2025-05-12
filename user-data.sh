#!/bin/bash
# Get RDS password from Secrets Manager
DB_PASSWORD_FROM_SECRET=$(aws secretsmanager get-secret-value --secret-id ${SECRET_ID} --query SecretString --output text)

{
  echo "DB_HOST=${DB_HOST}"
  echo "DB_USER=${DB_USER}"
  echo "DB_PASSWORD=$DB_PASSWORD_FROM_SECRET"
  echo "DB_NAME=${DB_NAME}"
  echo "S3_BUCKET_NAME=${S3_BUCKET_NAME}"
  echo "AWS_REGION=${AWS_REGION}"
} >> opt/app/.env

# Apply environment variables for the current session
export DB_HOST=${DB_HOST}
export DB_USER=${DB_USER}
export DB_PASSWORD=$DB_PASSWORD_FROM_SECRET
export DB_NAME=${DB_NAME}
export S3_BUCKET_NAME=${S3_BUCKET_NAME}
export AWS_REGION=${AWS_REGION}

# Start CloudWatch Agent
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/app/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
  -s

# Enable and start CloudWatch Agent service
sudo systemctl enable amazon-cloudwatch-agent
sudo systemctl start amazon-cloudwatch-agent