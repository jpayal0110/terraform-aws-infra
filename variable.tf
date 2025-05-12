variable "aws_profile" {
  description = "AWS CLI profile to use"
}

variable "aws_region" {
  description = "AWS region"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
}

variable "public_subnets" {
  description = "List of public subnet CIDRs"
}

variable "private_subnets" {
  description = "List of private subnet CIDRs"
}

variable "availability_zones" {
  description = "List of AZs"
}

variable "ami_id" {
  description = "Custom Image ID"
}

variable "key_name" {
  description = "Key name"
}

variable "domain_name" {
  description = "Domain name"
}

variable "rds_username" {
  description = "RDS Username"
  type        = string
}

variable "db_name" {
  description = "RDS db_name"
  type        = string
}

variable "webapp_acm_cert_arn" {
  type        = string
  description = "AWS Certificate Manager ARN for webapp domain"
}
 