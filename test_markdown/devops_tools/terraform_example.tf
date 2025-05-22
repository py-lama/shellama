# Example Terraform configuration for SheLLama DevOps tools testing

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

# Variables
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones to use"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b"]
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "key_name" {
  description = "SSH key name"
  type        = string
  default     = "pylama-key"
}

# Create a VPC
resource "aws_vpc" "pylama_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "pylama-vpc-${var.environment}"
    Environment = var.environment
    Project     = "PyLama"
  }
}

# Create public subnets
resource "aws_subnet" "public_subnets" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.pylama_vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name        = "pylama-public-subnet-${count.index}-${var.environment}"
    Environment = var.environment
    Project     = "PyLama"
  }
}

# Create private subnets
resource "aws_subnet" "private_subnets" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.pylama_vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + length(var.availability_zones))
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = false

  tags = {
    Name        = "pylama-private-subnet-${count.index}-${var.environment}"
    Environment = var.environment
    Project     = "PyLama"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "pylama_igw" {
  vpc_id = aws_vpc.pylama_vpc.id

  tags = {
    Name        = "pylama-igw-${var.environment}"
    Environment = var.environment
    Project     = "PyLama"
  }
}

# Create route table for public subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.pylama_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.pylama_igw.id
  }

  tags = {
    Name        = "pylama-public-route-table-${var.environment}"
    Environment = var.environment
    Project     = "PyLama"
  }
}

# Associate public subnets with public route table
resource "aws_route_table_association" "public_subnet_association" {
  count          = length(var.availability_zones)
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
  route_table_id = aws_route_table.public_route_table.id
}

# Create security group for EC2 instances
resource "aws_security_group" "pylama_sg" {
  name        = "pylama-sg-${var.environment}"
  description = "Security group for PyLama services"
  vpc_id      = aws_vpc.pylama_vpc.id

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SheLLama API access
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # APILama access
  ingress {
    from_port   = 5001
    to_port     = 5001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # WebLama access
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "pylama-sg-${var.environment}"
    Environment = var.environment
    Project     = "PyLama"
  }
}

# Create EC2 instance for PyLama services
resource "aws_instance" "pylama_instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.public_subnets[0].id
  vpc_security_group_ids = [aws_security_group.pylama_sg.id]

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y git python3 python3-pip python3-venv nginx
              
              # Clone repositories
              mkdir -p /opt/pylama
              cd /opt/pylama
              git clone https://github.com/py-lama/shellama.git
              git clone https://github.com/py-lama/apilama.git
              git clone https://github.com/py-lama/weblama.git
              
              # Setup services
              cd /opt/pylama/shellama
              python3 -m venv venv
              ./venv/bin/pip install -r requirements.txt
              
              cd /opt/pylama/apilama
              python3 -m venv venv
              ./venv/bin/pip install -r requirements.txt
              
              cd /opt/pylama/weblama
              npm install
              
              # Start services
              cd /opt/pylama/shellama
              nohup ./venv/bin/python app.py > shellama.log 2>&1 &
              
              cd /opt/pylama/apilama
              nohup ./venv/bin/python app.py > apilama.log 2>&1 &
              
              cd /opt/pylama/weblama
              nohup npm start > weblama.log 2>&1 &
              EOF

  tags = {
    Name        = "pylama-instance-${var.environment}"
    Environment = var.environment
    Project     = "PyLama"
  }
}

# Data source for Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# Create Elastic IP for the instance
resource "aws_eip" "pylama_eip" {
  instance = aws_instance.pylama_instance.id
  vpc      = true

  tags = {
    Name        = "pylama-eip-${var.environment}"
    Environment = var.environment
    Project     = "PyLama"
  }
}

# Create S3 bucket for backups
resource "aws_s3_bucket" "pylama_backups" {
  bucket = "pylama-backups-${var.environment}-${random_id.bucket_suffix.hex}"

  tags = {
    Name        = "pylama-backups-${var.environment}"
    Environment = var.environment
    Project     = "PyLama"
  }
}

# Random ID for S3 bucket name uniqueness
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Outputs
output "instance_public_ip" {
  description = "Public IP of the PyLama instance"
  value       = aws_eip.pylama_eip.public_ip
}

output "shellama_api_url" {
  description = "URL for SheLLama API"
  value       = "http://${aws_eip.pylama_eip.public_ip}:5000"
}

output "apilama_url" {
  description = "URL for APILama"
  value       = "http://${aws_eip.pylama_eip.public_ip}:5001"
}

output "weblama_url" {
  description = "URL for WebLama"
  value       = "http://${aws_eip.pylama_eip.public_ip}:3000"
}
