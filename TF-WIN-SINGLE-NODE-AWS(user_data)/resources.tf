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

resource "aws_instance" "windows" {
  ami                         = "ami-0d3734a9c753bb2a7"
  instance_type               = "t2.micro"
  key_name                    = var.key_pair
  subnet_id                   = aws_subnet.pub_subnet.id
  vpc_security_group_ids      = ["${aws_security_group.DevSGRP.id}"]
  tags = {
    Name = "${var.environment}-windows-PUBLIC"
    Tag  = "${var.environment}"
  }
  user_data     = <<EOF
      <powershell>
      net user ${var.INSTANCE_USERNAME} '${var.admin_password}' /add /y
      net localgroup administrators ${var.INSTANCE_USERNAME} /add
      winrm quickconfig -q
      winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="300"}'
      winrm set winrm/config '@{MaxTimeoutms="1800000"}'
      winrm set winrm/config/service '@{AllowUnencrypted="true"}'
      winrm set winrm/config/service/auth '@{Basic="true"}'
      netsh advfirewall firewall add rule name="WinRM 5985" protocol=TCP dir=in localport=5985 action=allow
      netsh advfirewall firewall add rule name="WinRM 5986" protocol=TCP dir=in localport=5986 action=allow
      net stop winrm
      sc.exe config winrm start=auto
      net start winrm
      Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
      $LocalTempDir = $env:TEMP; $ChromeInstaller = "ChromeInstaller.exe"; (new-object    System.Net.WebClient).DownloadFile('http://dl.google.com/chrome/install/375.126/chrome_installer.exe', "$LocalTempDir\$ChromeInstaller"); & "$LocalTempDir\$ChromeInstaller" /silent /install; $Process2Monitor =  "ChromeInstaller"; Do { $ProcessesFound = Get-Process | ?{$Process2Monitor -contains $_.Name} | Select-Object -ExpandProperty Name; If ($ProcessesFound) { "Still running: $($ProcessesFound -join ', ')" | Write-Host; Start-Sleep -Seconds 2 } else { rm "$LocalTempDir\$ChromeInstaller" -ErrorAction SilentlyContinue -Verbose } } Until (!$ProcessesFound)
      </powershell>
      EOF

  #   provisioner "file" {
  #   source = "powershell-install-choco.ps1"
  #   destination = "C:/powershell-install-choco.ps1"
  # }
  # connection {
  #   host = coalesce(self.public_ip, self.private_ip)
  #   type = "winrm"
  #   timeout = "10m"
  #   user = var.INSTANCE_USERNAME
  #   password = var.admin_password
  # }
}

resource "aws_eip" "Dev_EIP" {
  vpc         = true
  instance    = aws_instance.windows.id
  # depends_on  = [aws_internet_gateway.Dev_IGW]
}

output "ip" {         # terraform Public IP output
  value = "${aws_instance.windows.public_ip}"
}