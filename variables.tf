variable "aws_region" {
  description = "The AWS region to deploy the resources in."
  type        = string
  default     = "us-east-1"
}

variable "vpc_name" {
  description = "name of the VPC to be used"
  type        = string
  default     = "webshop-vpc"
}

variable "vpc_cidr" {
  description = "CIDR range of the VPC"
  type        = string
  default     = "10.0.0.0/16"
}
#make public and private subnets
variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

#ec2 EMI variable
variable "ec2_ami" {
  description = "AMI ID for the EC2 instance"
  type        = string
  default     = "ami-0360c520857e3138f" #AMI
}
#ec2 instance type
variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

#security group ingress rules
variable "sg_ingress_rules" {
  description = "Security group ingress rules"
  type = map(object({
    cidr_ipv4   = string
    to_port     = number
    ip_protocol = string
  }))
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway"
  type        = bool
  default     = true
}

variable "enable_vpn_gateway" {
  description = "Enable VPN Gateway"
  type        = bool
  default     = false
}

variable "create_igw" {
  description = "Create Internet Gateway"
  type        = bool
  default     = true
}

variable "create_private_nat_gateway_route" {
  description = "Create private route to NAT Gateway"
  type        = bool
  default     = true
}

variable "enable_flow_log" {
  description = "Enable VPC flow logs"
  type        = bool
  default     = true
}

variable "create_flow_log_cloudwatch_iam_role" {
  description = "Create IAM role for flow logs CloudWatch"
  type        = bool
  default     = true
}

variable "create_flow_log_cloudwatch_log_group" {
  description = "Create CloudWatch log group for flow logs"
  type        = bool
  default     = true
}

variable "associate_public_ip_address" {
  description = "Associate public addess with server or not"
  type        = bool
  default     = true
}

variable "security_group_name" {
  description = "Name of the security group"
  type        = string
  default     = "webserver-sg"
}
variable "security_group_description" {
  description = "Description of the security group"
  type        = string
  default     = "Allow HTTP and SSH inbound traffic"
}

variable "webserver_name" {
  description = "Webserver name"
  type        = string
  default     = "webserver-instance"
}