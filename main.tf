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
  access_key = "redacted"
  secret_key = "redacted"
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
