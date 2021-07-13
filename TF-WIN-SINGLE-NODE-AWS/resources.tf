// Create VPC Virtual Private Cloud (VPC)
resource "aws_vpc" "vpc" {
  cidr_block = "10.40.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name        = "${var.environment}"
    Environment = "${var.environment}"
  }
}

// Create Public Subnet
resource "aws_subnet" "pub_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "${var.pub_subnet}"
  tags = {
    Environment = "${var.environment}"
    Name        = "${var.environment}"
  }
}

// Create EC2 Key Pair 
resource "tls_private_key" "Dev" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "Dev" {
  key_name   = var.key_pair
  public_key = tls_private_key.Dev.public_key_openssh
  }
  resource "local_file" "Dev" {
  filename = pathexpand("./Dev.pem") # store EC2 keypair to your directory
  sensitive_content = "${tls_private_key.Dev.private_key_pem}"
}

// Create Internet gateway allow to access the server
resource "aws_internet_gateway" "Dev_IGW" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "${var.environment}"
    Environment = "${var.environment}"
  }
}

// Create Route table
resource "aws_route_table" "DevRT" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Dev_IGW.id
  }
  tags = {
    Name        = "${var.environment}"
    Environment = "${var.environment}"
  }
}

// Route table associations
resource "aws_route_table_association" "PUBRTassociation" {
  subnet_id      = aws_subnet.pub_subnet.id
  route_table_id = aws_route_table.DevRT.id
}

// Create Security Group and allow inbound and outbound
resource "aws_security_group" "DevSGRP" {
  name        = "DevSGRP"
  description = "Default security group to allow inbound/outbound from the VPC"
  vpc_id      = aws_vpc.vpc.id
  depends_on  = [aws_vpc.vpc]

  ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
  }

  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }
  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = "true"
  }
  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment = "${var.environment}"
    Name        = "${var.environment}"
  }
}

// AWS EC2 instance Provision
resource "aws_instance" "windows" {
  ami                         = "ami-0d3734a9c753bb2a7" # Windows 2019 Base image
  instance_type               = "t2.micro" # Free EC2
  key_name                    = var.key_pair
  subnet_id                   = aws_subnet.pub_subnet.id
  vpc_security_group_ids = ["${aws_security_group.DevSGRP.id}"]
  tags = {
    Name = "${var.environment}-windows-PUBLIC"
    Tag  = "${var.environment}"
  }
}

resource "aws_eip" "Dev_EIP" {
  vpc = true
  instance                  = aws_instance.windows.id
  # associate_with_private_ip = "10.0.0.12"
  depends_on                = [aws_internet_gateway.Dev_IGW]
}