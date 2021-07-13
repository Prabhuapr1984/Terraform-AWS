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