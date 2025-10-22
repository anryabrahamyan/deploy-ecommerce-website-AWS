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

resource "aws_security_group" "web_sg" {
  name        = var.security_group_name
  description = var.security_group_description
  vpc_id      = module.vpc.vpc_id
  #define ingress rules for each rule in var.sg_ingress_rules
  dynamic "ingress" {
    for_each = var.sg_ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.ip_protocol
      cidr_blocks = [ingress.value.cidr_ipv4]
    }
  }
  #configure egress rules for each rule in var.sg_egress_rules
  dynamic "egress" {
    for_each = var.sg_egress_rules
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.ip_protocol
      cidr_blocks = [egress.value.cidr_ipv4]
    }
  }
}

resource "aws_launch_template" "server_template" {
  region          = var.aws_region
  name            = var.webserver_name
  default_version = var.launch_template_version
  description     = "launch template for ec2 servers"

  image_id                             = var.ec2_ami
  instance_initiated_shutdown_behavior = "terminate"
  instance_type = var.ec2_instance_type

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 64
    instance_metadata_tags      = "enabled"
  }


  network_interfaces {
    associate_public_ip_address = var.associate_public_ip_address
    delete_on_termination       = true
    security_groups = [aws_security_group.web_sg.id]
  }
  # vpc_security_group_ids = [aws_security_group.web_sg.id]
  user_data              = base64encode(local.bootstrap_script)
}

module "asg"{
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "9.0.2"
  # Autoscaling group
  name = var.asg_group_name

  min_size                  = 2
  max_size                  = 4
  desired_capacity          = 2
  wait_for_capacity_timeout = 0
  health_check_type         = "ELB"
  vpc_zone_identifier       = module.vpc.public_subnets

  instance_refresh = {
    strategy = "Rolling"
    preferences = {
      checkpoint_delay       = 600
      checkpoint_percentages = [35, 70, 100]
      instance_warmup        = 100
      min_healthy_percentage = 50
      max_healthy_percentage = 100
    }
    triggers = ["launch_template"]
  }

  # Launch template
  create_launch_template = false
  launch_template_id     = aws_launch_template.server_template.id
  launch_template_version = "$Latest"

  tags = {
    Environment = "dev"
  }
}

resource "aws_autoscaling_policy" "asg_policy" {
  depends_on = [ module.asg ]
  for_each = var.scaling_policies

  name                      = each.value.name != null ? each.value.name : each.key
  policy_type               = each.value.policy_type
  autoscaling_group_name    = module.asg.autoscaling_group_name
  estimated_instance_warmup = each.value.estimated_instance_warmup
  enabled                   = lookup(each.value, "enabled", true)

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = each.value.target_tracking_configuration.predefined_metric_specification.predefined_metric_type
    }
    target_value = each.value.target_tracking_configuration.target_value
  }
}

module "elb_http" {
  source  = "terraform-aws-modules/elb/aws"
  version = "4.0.2"
  name = var.elb_name

  subnets         = module.vpc.public_subnets
  security_groups = [aws_security_group.web_sg.id]
  internal        = false

  listener = [
    {
      instance_port     = 80
      instance_protocol = "HTTP"
      lb_port           = 80
      lb_protocol       = "HTTP"
    }
  ]

  health_check = {
    target              = "HTTP:80/"
    interval            = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
  }


  tags = {
    Owner       = "user"
    Environment = "dev"
  }
}

# Create a new load balancer attachment
resource "aws_autoscaling_attachment" "elb_attachment" {
  autoscaling_group_name = module.asg.autoscaling_group_name
  elb                    = module.elb_http.elb_name
}