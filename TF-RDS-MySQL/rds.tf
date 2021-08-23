# Create New VPC with the 10.x.x.x CIDR block, Subnet, IGW
resource "aws_vpc" "vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "${var.name}"
  }
}

resource "aws_subnet" "rds_sub1" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "10.0.20.0/24"
  availability_zone= "ap-southeast-1a"
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.name}"
  }
}
resource "aws_subnet" "rds_sub2" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "10.0.30.0/24"
  availability_zone= "ap-southeast-1b"
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.name}"
  }
}

resource "aws_internet_gateway" "Dev_IGW" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "${var.name}"
    Environment = "${var.environment}"
  }
}

# Default DHCP options
resource "aws_vpc_dhcp_options" "vpc_dhcp_options" {
  domain_name_servers = ["AmazonProvidedDNS"]
}

resource "aws_db_subnet_group" "default" {
  name        = "${var.rds_instance_identifier}-subnet-group"
  description = "Terraform example RDS subnet group"
  subnet_ids = [aws_subnet.rds_sub1.id, aws_subnet.rds_sub2.id]
}

resource "aws_security_group" "default" {
  name        = "terraform_rds_security_group"
  description = "Terraform example RDS MySQL server"
  vpc_id      = "${aws_vpc.vpc.id}"
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    self = true
  }
  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.name}"
  }
}

resource "aws_db_instance" "default" {
  identifier                = "${var.rds_instance_identifier}"
  allocated_storage         = 5
  engine                    = "mysql"
  engine_version            = "5.6.35"
  instance_class            = "db.t2.micro"
  name                      = "${var.database_name}"
  username                  = "${var.database_user}"
  password                  = "${var.database_password}"
  db_subnet_group_name      = "${aws_db_subnet_group.default.id}"
  vpc_security_group_ids    = ["${aws_security_group.default.id}"]
  skip_final_snapshot       = true
  publicly_accessible = true
  final_snapshot_identifier = "Ignore"
}

resource "aws_db_parameter_group" "default" {
  name        = "${var.rds_instance_identifier}-param-group"
  description = "Terraform example parameter group for mysql5.6"
  family      = "mysql5.6"
  parameter {
    name  = "character_set_server"
    value = "utf8"
  }
  parameter {
    name  = "character_set_client"
    value = "utf8"
  }
}