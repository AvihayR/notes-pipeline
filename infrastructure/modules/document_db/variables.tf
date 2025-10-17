variable "master_username" {
  type = string
}

variable "master_password" {
  type = string
}

variable "az_list" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "allowed_cidr_blocks" {
  type = list(string)
}
