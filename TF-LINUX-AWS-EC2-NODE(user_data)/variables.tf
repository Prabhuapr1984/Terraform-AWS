variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}
variable "AWS_REGION" {}

variable "key_pair" {
  type    = string
  default = "Dev"
} 

variable "environment" {
  type    = string
  default = "Dev"
}

variable "pub_subnet" {
  default = "10.40.5.0/24"
}

variable "instance_username" {
  default = "lx-admin"
}

variable "instance_password" {
  description = "linux Administrator password to login as."
	default = "password@123456"
}

variable "instance_count" {
  default = "1"
}