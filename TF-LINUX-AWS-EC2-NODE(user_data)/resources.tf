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

// Default DHCP options
resource "aws_vpc_dhcp_options" "vpc_dhcp_options" {
  # domain_name         = "eu-west-1.compute.internal"
  domain_name_servers = ["AmazonProvidedDNS"]
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

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = "${aws_vpc.vpc.id}"
  dhcp_options_id = aws_vpc_dhcp_options.vpc_dhcp_options.id
}

resource "aws_instance" "linux" {
  ami                         = "ami-0d6ba217f554f6137" # Red Hat Enterprise Linux 8 (HVM), SSD Volume Type
  instance_type               = "t2.micro"
  key_name                    = var.key_pair
  subnet_id                   = aws_subnet.pub_subnet.id
  vpc_security_group_ids      = ["${aws_security_group.DevSGRP.id}"]
  associate_public_ip_address = true
  tags = {
    Name = "${var.environment}-linux-PUBLIC"
    Tag  = "${var.environment}"
  }
  user_data = <<-EOF
              #!/bin/bash
              useradd ${var.instance_username} -p ${var.instance_password}
              curl -k -O https://packages.chef.io/files/stable/chef-workstation/21.2.278/el/8/chef-workstation-21.2.278-1.el7.x86_64.rpm
              rpm -i chef-workstation-21.2.278-1.el7.x86_64.rpm --nosignature
            EOF   
}

resource "aws_eip" "Dev_EIP" {
  vpc         = true
  instance    = aws_instance.linux.id
  depends_on  = [aws_internet_gateway.Dev_IGW]
}

output "public_ip" {
  description = "Public IPs of created instances. "
  value       = aws_instance.linux.public_ip
}