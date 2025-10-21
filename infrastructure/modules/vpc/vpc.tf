resource "aws_vpc" "notes_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "notes_vpc"
  }
}

output "vpc_id" {
  value = aws_vpc.notes_vpc.id
}

output "vpc_cidr_block" {
  value = aws_vpc.notes_vpc.cidr_block
}
