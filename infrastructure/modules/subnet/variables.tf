variable "vpc_id" {
  type = string
}

variable "cidr_block" {
  type = string
}

variable "az" {
  type = string
}

variable "subnet_type" {
  type = string

  validation {
    condition     = var.subnet_type == "private" || var.subnet_type == "public"
    error_message = "Subnet type must be of type string, and assigned the literal string of 'public' or 'private'"
  }
}

variable "description" {
  type = string
}
