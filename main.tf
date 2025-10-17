module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "webshop-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway               = true
  single_nat_gateway               = true
  enable_vpn_gateway               = false
  create_igw                       = true
  create_private_nat_gateway_route = true
  enable_flow_log                  = true
  create_flow_log_cloudwatch_iam_role = true
  create_flow_log_cloudwatch_log_group = true
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}