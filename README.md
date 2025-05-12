# **Terraform AWS Infrastructure Setup**

This repository contains the Terraform configurations for setting up a cloud infrastructure on AWS. It includes the creation of a **Virtual Private Cloud (VPC)** with 3 public subnets, 3 private subnets, and necessary route tables for both types of subnets.

## **Prerequisites**

- Terraform installed on your local machine. You can download Terraform from [here](https://www.terraform.io/downloads.html).
- AWS CLI installed and configured with the necessary IAM permissions. To configure AWS CLI, run:
  ```bash
  aws configure
  ```

## **Getting Started**

1. **Clone this repository:**

   ```bash
   git clone <repo_url>
   cd <repo_name>
   ```

2. **Set up your AWS credentials**:
   Ensure you have set up your AWS access keys or use IAM roles if running in an EC2 instance. Use the AWS CLI or environment variables to authenticate.

3. **Terraform Initialization**:
   Initialize the Terraform configuration. This will download the required provider plugins.

   ```bash
   terraform init
   ```

4. **Review the Terraform Configuration**:
   - The configuration consists of the following files:
     - **vpc.tf**: Defines the VPC, subnets, and networking components.
     - **subnet.tf**: Defines the 3 public and 3 private subnets.
     - **version.tf**: Specifies the required Terraform version and provider configuration.
     - **variable.tf**: Defines the variables used throughout the Terraform configuration.

5. **Plan the infrastructure**:
   Run the `terraform plan` command to see a preview of the changes Terraform will apply to your AWS account.

   ```bash
   terraform plan
   ```

6. **Apply the configuration**:
   Apply the configuration to create the infrastructure. Terraform will ask for confirmation before making any changes.

   ```bash
   terraform apply
   ```

   Once the infrastructure is successfully created, you will receive the output with details like the VPC ID, subnet IDs, etc.

7. **Verify the infrastructure**:
   Go to your AWS Management Console and check the resources that have been created:
   - A VPC with the specified CIDR block.
   - 3 public subnets and 3 private subnets.
   - Route tables associated with the public and private subnets.
   - An Internet Gateway connected to the public subnet.

8. **Destroy the infrastructure** (optional):
   If you want to tear down the infrastructure, use the following command:

   ```bash
   terraform destroy
   ```

9. **SSL Certificate Import (Demo Environment)**

The demo environment uses an SSL certificate purchased from Namecheap (or any third-party CA). This certificate must be imported into AWS Certificate Manager (ACM) manually using the AWS CLI.

- 🔧 Required Files:

   - Make sure the following files are present in your working directory (usually from the CA after validation):

   - demo_jpayalprod_me.crt – Your public SSL certificate

   - demo_jpayalprod_me.ca-bundle – The CA chain bundle

   - private.key – The private key used during CSR generation

**📅 AWS CLI Import Command:**
```bash
aws acm import-certificate \
  --certificate fileb://demo_jpayalprod_me/demo_jpayalprod_me.crt \
  --private-key fileb://demo_jpayalprod_me/private.key \
  --certificate-chain fileb://demo_jpayalprod_me/demo_jpayalprod_me.ca-bundle \
  --region us-east-1 \
  --profile demo-user
```

🔐 This will return a CertificateArn that must be used in the HTTPS listener configuration of your Application Load Balancer (ALB).

Once imported, attach this certificate to your ALB HTTPS (port 443) listener via the AWS Console or Terraform.
