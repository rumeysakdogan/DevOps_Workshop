# Configure the AWS Provider

locals {
  team        = "api_mgmt_dev"
  application = "corp_api"
  server_name = "ec2-${var.environment}-api-${var.variables_sub_az}"
}

locals {
  service_name = "Automation"
  app_team     = "Cloud Team"
  createdby    = "terraform"
}

locals {
  # Common tags to be assigned to all resources
  common_tags = {
    Name      = local.server_name
    Owner     = local.team
    App       = local.application
    Service   = local.service_name
    AppTeam   = local.app_team
    CreatedBy = local.createdby
  }
}

data "aws_availability_zones" "available" {}
data "aws_region" "current" {}

#Define the VPC 
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name        = var.vpc_name
    Environment = "demo_environment"
    Terraform   = "true"
  }

  enable_dns_hostnames = true
}

# resource "aws_subnet" "variables-subnet" {
#   vpc_id            = aws_vpc.vpc.id
#   cidr_block        = var.variables_sub_cidr
#   availability_zone = var.variables_sub_az
#   tags = {
#     Name = "sub_variables-${var.variables_sub_az}"
#   }
# }
# #Deploy the public subnets
# resource "aws_subnet" "public_subnets" {
#   for_each                = var.public_subnets
#   vpc_id                  = aws_vpc.vpc.id
#   cidr_block              = cidrsubnet(var.vpc_cidr, 8, each.value + 100)
#   availability_zone       = tolist(data.aws_availability_zones.available.names)[each.value]
#   map_public_ip_on_launch = true

#   tags = {
#     Name      = each.key
#     Terraform = "true"
#   }
# }

# #Create route tables for public and private subnets
# resource "aws_route_table" "public_route_table" {
#   vpc_id = aws_vpc.vpc.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.internet_gateway.id
#     #nat_gateway_id = aws_nat_gateway.nat_gateway.id
#   }
#   tags = {
#     Name      = "demo_public_rtb"
#     Terraform = "true"
#   }
# }
# #Create route table associations
# resource "aws_route_table_association" "public" {
#   depends_on     = [aws_subnet.public_subnets]
#   route_table_id = aws_route_table.public_route_table.id
#   for_each       = aws_subnet.public_subnets
#   subnet_id      = each.value.id
# }

# #Create Internet Gateway
# resource "aws_internet_gateway" "internet_gateway" {
#   vpc_id = aws_vpc.vpc.id
#   tags = {
#     Name = "demo_igw"
#   }
# }

resource "random_string" "random" {
  length = 10
}

# Terraform Data Block - To Lookup Latest Ubuntu 20.04 AMI Image
# data "aws_ami" "ubuntu" {
#   most_recent = true

#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }

#   owners = ["099720109477"]
# }

# resource "aws_security_group" "ingress-ssh" {
#   name   = "allow-all-ssh"
#   vpc_id = aws_vpc.vpc.id
#   ingress {
#     cidr_blocks = [
#       "0.0.0.0/0"
#     ]
#     from_port = 22
#     to_port   = 22
#     protocol  = "tcp"
#   }
#   // Terraform removes the default rule
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# resource "aws_security_group" "vpc-web" {
#   name        = "vpc-web-${terraform.workspace}"
#   vpc_id      = aws_vpc.vpc.id
#   description = "Web Traffic"
#   ingress {
#     description = "Allow Port 80"
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     description = "Allow Port 443"
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     description = "Allow all ip and ports outbound"
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# Terraform Resource Block - To Build Web Server in Public Subnet
# resource "aws_instance" "web_server" {
#   ami                         = data.aws_ami.ubuntu.id
#   instance_type               = "t2.micro"
#   subnet_id                   = aws_subnet.variables-subnet.id
#   security_groups             = [aws_security_group.ingress-ssh.id, aws_security_group.vpc-web.id]
#   associate_public_ip_address = true
#   key_name                    = "FirstKey"

#   tags = local.common_tags

#   lifecycle {
#     ignore_changes = [security_groups]
#   }
# }

resource "aws_subnet" "list_subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.200.0/24"
  availability_zone = var.us-east-1-azs[0]
}
