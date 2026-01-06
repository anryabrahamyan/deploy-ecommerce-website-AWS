# Deploy E-commerce Website on AWS

This repository contains Terraform configurations to deploy a scalable e-commerce website infrastructure on AWS. The setup includes a VPC with public and private subnets, an Auto Scaling Group (ASG) with EC2 instances running Nginx web servers, and an Elastic Load Balancer (ELB) to distribute traffic.

## What It Does

The Terraform code provisions the following AWS resources:

- **VPC**: A virtual private cloud with public and private subnets across multiple availability zones.
- **Security Groups**: Configurable ingress and egress rules for secure access (e.g., HTTP, HTTPS, SSH).
- **Launch Template**: Defines the EC2 instance configuration, including AMI, instance type, and user data script.
- **Auto Scaling Group (ASG)**: Manages 2 EC2 instances (scalable to 4) with health checks and scaling policies based on CPU utilization.
- **Elastic Load Balancer (ELB)**: An HTTP load balancer that routes traffic to the ASG instances.
- **EC2 Instances**: Ubuntu-based servers with Nginx installed, displaying the instance ID and availability zone on a simple web page.

The web servers fetch their metadata (instance ID and AZ) via AWS EC2 metadata service and display it on the homepage, demonstrating dynamic content based on the instance.

## Architecture

```
Internet
    |
    v
Elastic Load Balancer (HTTP)
    |
    v
Auto Scaling Group (2-4 instances)
    |
    v
EC2 Instances (Nginx web servers)
    - Public subnets
    - Security groups
    - User data script for setup
    |
    v
VPC with public/private subnets
```

## Prerequisites

- **AWS Account**: With appropriate permissions to create VPC, EC2, ELB, and related resources.
- **Terraform**: Version 1.0+ installed locally.
- **AWS CLI**: Configured with your credentials (`aws configure`).
- **Git**: For cloning the repository.

## Usage

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/anryabrahamyan/deploy-ecommerce-website-AWS.git
   cd deploy-ecommerce-website-AWS
   ```

2. **Set up OIDC for CI/CD** (optional, for automated deployments):
   Deploy the CloudFormation template to create an OIDC provider and IAM role for GitHub Actions:
   ```bash
   aws cloudformation deploy --template-file templates/oidc-setup.yaml --stack-name github-oidc-stack --capabilities CAPABILITY_IAM
   ```
   Note the output `RoleArn` for use in GitHub repository secrets.

3. **Initialize Terraform**:
   ```bash
   terraform init
   ```

4. **Review the Plan**:
   ```bash
   terraform plan
   ```

5. **Apply the Configuration**:
   ```bash
   terraform apply
   ```
   Type `yes` when prompted.

6. **Access the Website**:
   After deployment, note the `elb_dns_name` output. Visit `http://<elb_dns_name>` in your browser to see the website displaying instance details.

7. **Destroy Resources** (when done):
   ```bash
   terraform destroy
   ```

## Configuration

Customize the deployment using variables in `variables.tf`:

- `aws_region`: AWS region (default: us-east-1)
- `vpc_cidr`: VPC CIDR block
- `public_subnets` / `private_subnets`: Subnet configurations
- `ec2_instance_type`: Instance size (default: t3.medium)
- `asg_group_name`: ASG name
- `elb_name`: ELB name
- Security group rules, scaling policies, etc.

Example: To change instance type, update `variables.tf` or pass via command line:
```bash
terraform apply -var="ec2_instance_type=t3.small"
```

## Outputs

After `terraform apply`, the following outputs are available:

- `elb_dns_name`: DNS name of the Elastic Load Balancer (use this to access the site).

## Security

- Instances are launched in public subnets with public IPs for demo purposes.
- Security groups allow HTTP (80), HTTPS (443), and SSH (22) from anywhere (restrict in production).
- ELB uses HTTP only (recently changed from HTTPS).
- No sensitive data is hardcoded; use AWS Secrets Manager for production secrets.
- For CI/CD pipelines, use CloudFormation to set up OIDC authentication for secure access to AWS resources.

## Files Overview

- `main.tf`: Main Terraform configuration.
- `variables.tf`: Input variables.
- `outputs.tf`: Output values.
- `locals.tf`: Local values (e.g., user data script).
- `templates/userdata.sh`: Bootstrap script for EC2 instances (installs Nginx, fetches metadata, generates HTML).
- `.github/workflows/`: CI/CD workflows for deployment, security checks and initial account configuration for OIDC
