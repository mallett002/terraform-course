# Define a provider (AWS)
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

# set up aws account:
provider "aws" {
  region     = "us-east-1"
  access_key = "REDACTED"
  secret_key = "REDACTED"
}

# Create a resource
# resource "<provider>_<resource_type>" "name" {
#     config options... {
#     key = "value"
#     key2 = "value"
# }

# deploy ec2 instance:
# resource "aws_instance" "my-ec2-from-tf" {
#     ami                 = "ami-0f403e3180720dd7e"
#     instance_type       = "t2.micro"
#     subnet_id           = "subnet-0bf22861aee1ce37e"

#     tags = {
#         Name = "willmally"
#     }
# }

# # Create vpc
# resource "aws_vpc" "first-vpc" {
#   cidr_block = "10.0.0.0/16"

#   tags = {
#     Name = "prod"
#   }
# }

# # subnet for vpc
# resource "aws_subnet" "subnet-1" {
#   vpc_id     = aws_vpc.first-vpc.id
#   cidr_block = "10.0.1.0/24"

#   tags = {
#     Name = "prod-subnet"
#   }
# }

#-------------------------------------------------------------------------
# ************  Sample project: EC2 web server  ************
#-------------------------------------------------------------------------
# Steps:
# 1. Create VPC
# 2. Create Internet Gateway
# 3. Create Custom Route Table
# 4. Create a subnet
# 5. Associate subnet with route table
# 6. Create Security Group to allow inbound from port 22, 80, 443
# 7. Create network interface with ip in the subnet that was created in step 4
# 8. Assign an elastic IP to network interface created in step 7
# 9. Create ubuntu server and install/enable apache2

variable "subnet_prefix" {
  description = "cidr block for subnet"
  default     = "10.0.1.0/24"
  #   type        = string # type constraints on variable (TF supports many types)
}

# vpc
resource "aws_vpc" "prod-vpc" {
  cidr_block = "10.0.0.0/16"
}

# internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.prod-vpc.id

  tags = {
    Application = "tf-tutorial"
  }
}

# egress only internet gateway
resource "aws_egress_only_internet_gateway" "egw" {
  vpc_id = aws_vpc.prod-vpc.id

  tags = {
    Application = "tf-tutorial"
  }
}

# Route table
resource "aws_route_table" "prod-rt" {
  vpc_id = aws_vpc.prod-vpc.id

  # default route (all traffic)
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  # default route for ipv6
  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_egress_only_internet_gateway.egw.id
  }

  tags = {
    Application = "tf-tutorial"
  }
}

# subnet
resource "aws_subnet" "web-server-subnet" {
  vpc_id               = aws_vpc.prod-vpc.id
  cidr_block           = var.subnet_prefix[0].cidr_block
  availability_zone_id = "use1-az1"

  tags = {
    Application = "tf-tutorial"
    Name        = var.subnet_prefix[0].name
  }
}

# associate subnet with route table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.web-server-subnet.id
  route_table_id = aws_route_table.prod-rt.id
}

# security group with inbound http and ssh
resource "aws_security_group" "server_sg" {
  name        = "server_sg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.prod-vpc.id

  tags = {
    Application = "tf-tutorial"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Network interface with private IP in the subnet
resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_subnet.web-server-subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.server_sg.id]

  tags = {
    Application = "tf-tutorial"
  }
}

# Assign an elastic IP to network interface
resource "aws_eip" "server-eip" {
  vpc                       = true
  network_interface         = aws_network_interface.web-server-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.gw, aws_egress_only_internet_gateway.egw]
  #   instance = aws_instance.web.id

  tags = {
    Application = "tf-tutorial"
  }
}

# Output the public ip for the web server
output "server_public_ip" {
  value = aws_eip.server-eip.public_ip
}

# ubuntu server
resource "aws_instance" "web-server-instance" {
  ami               = "ami-080e1f13689e07408"
  instance_type     = "t2.micro"
  availability_zone = "us-east-1c"
  key_name          = "tf-key-pair"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.web-server-nic.id
  }

  #   user_data         = "apache-install.sh"
  user_data = <<-EOF
            #!/bin/bash
            sudo apt update -y
            sudo apt install apache2 -y
            sudo systemctl start apache2
            sudo bash -c 'echo your very first web server > /var/www/html/index.html'
            EOF

  #   security_groups   = [aws_security_group.server_sg.id]
  #   subnet_id         = aws_subnet.web-server-subnet.id


  tags = {
    Application = "tf-tutorial"
  }
}

output "server_private_ip" {
  value = aws_instance.web-server-instance.private_ip
}

output "server_private_id" {
  value = aws_instance.web-server-instance.id
}
