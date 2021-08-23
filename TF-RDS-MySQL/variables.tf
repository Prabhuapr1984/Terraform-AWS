variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}
variable "AWS_REGION" {}

variable "rds_instance_identifier" {
    default = "pjadmin"
}
variable "database_name" {
    default = "pjsqlDB"
    type = string
}

variable "database_user" {
    default = "pjadmin"
    type = string
}

variable "database_password" {
  default = "password123456"
}

variable "name" {
    default = "TF-RDS"
}

variable "environment" {
    default = "staging"
}