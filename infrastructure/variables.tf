variable "region" {
  description = "AWS Region to deploy infra to"
  default     = "eu-central-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}


