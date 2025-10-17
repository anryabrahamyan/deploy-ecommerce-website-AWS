module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.4.0"
  name    = var.vpc_name
  cidr    = var.vpc_cidr

  azs             = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway                   = var.enable_nat_gateway
  single_nat_gateway                   = var.single_nat_gateway
  enable_vpn_gateway                   = var.enable_vpn_gateway
  create_igw                           = var.create_igw
  create_private_nat_gateway_route     = var.create_private_nat_gateway_route
  enable_flow_log                      = var.enable_flow_log
  create_flow_log_cloudwatch_iam_role  = var.create_flow_log_cloudwatch_iam_role
  create_flow_log_cloudwatch_log_group = var.create_flow_log_cloudwatch_log_group
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}


module "ec2-instance" {
  depends_on = [module.vpc]
  source     = "terraform-aws-modules/ec2-instance/aws"
  version    = "6.1.2"

  name                        = var.webserver_name
  ami                         = var.ec2_ami #AMI for ubuntu server
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = var.associate_public_ip_address
  availability_zone           = "${var.aws_region}a"
  instance_type               = var.ec2_instance_type
  #no EBS volume created for now
  # ebs_volumes = {
  #   main = {
  #     encrypted                      = true
  #     iops                           = 200
  #     size                           = 10
  #     type                           = "gp3"
  #     device_name                    = "/dev/sdb"
  #     skip_destroy                   = false
  #     stop_instance_before_detaching = true
  #   }
  # }

  security_group_name          = var.security_group_name
  security_group_description   = var.security_group_description
  security_group_ingress_rules = var.sg_ingress_rules
  security_group_vpc_id        = module.vpc.vpc_id
  user_data                    = local.bootstrap_script
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
