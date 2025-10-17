variable "vpc_id" {
  type = string
}

variable "ecr_repo_urls" {
  type = map(string)
}

variable "backend_url" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "db_url" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "alb_tg_frontend_arn" {
  type = string
}

variable "alb_tg_backend_arn" {
  type = string
}

variable "alb_sg_ids" {
  type = list(string)
}
