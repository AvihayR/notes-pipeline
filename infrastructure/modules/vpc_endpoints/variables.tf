variable "vpc_id" {
  type = string
}

variable "region" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "route_table_ids" {
  type = list(string)
}
