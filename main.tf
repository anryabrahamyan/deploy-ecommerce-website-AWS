module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.4.0"
  name    = "webshop-vpc"
  cidr    = "10.0.0.0/16"

  azs             = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway                   = true
  single_nat_gateway                   = true
  enable_vpn_gateway                   = false
  create_igw                           = true
  create_private_nat_gateway_route     = true
  enable_flow_log                      = true
  create_flow_log_cloudwatch_iam_role  = true
  create_flow_log_cloudwatch_log_group = true
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}


module "ec2-instance" {
  depends_on = [module.vpc]
  source     = "terraform-aws-modules/ec2-instance/aws"
  version    = "6.1.2"

  name                        = "webserver-instance"
  ami                         = "ami-0360c520857e3138f"#AMI for ubuntu server
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  availability_zone           = "${var.aws_region}a"
  instance_type               = "t3.medium"
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

  security_group_name        = "webserver-sg"
  security_group_description = "Allow HTTP and SSH inbound traffic"
  security_group_ingress_rules = {
    http = {
      cidr_ipv4   = "0.0.0.0/0"
      to_port     = 80
      ip_protocol = "tcp"
    }
    ssh = {
      cidr_ipv4   = "0.0.0.0/0"
      to_port     = 22
      ip_protocol = "tcp"
    }
  }
  security_group_vpc_id = module.vpc.vpc_id
  user_data = file("${path.module}/templates/userdata.sh")
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
