resource "aws_vpc" "notes_vpc" {
  cidr_block = var.vpc_cidr
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
