variable "region" {
  description = "AWS Region to deploy infra to"
  default     = "eu-central-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "availability_zone" {
  default = {
    "az-a" = "eu-central-1a"
    "az-b" = "eu-central-1b"
  }
}

variable "public_subnet_cidr_block" {
  default = {
    "az-a" = "10.0.100.0/24"
    "az-b" = "10.0.200.0/24"
  }
}

variable "private_subnet_cidr_block" {
  default = {
    "az-a" = "10.0.10.0/24"
    "az-b" = "10.0.20.0/24"
  }
}


variable "db_user" {
  type = string
}

variable "db_password" {
  type = string
}


