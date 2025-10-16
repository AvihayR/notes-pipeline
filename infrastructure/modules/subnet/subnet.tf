resource "aws_subnet" "subnet" {
  vpc_id            = var.vpc_id
  cidr_block        = var.cidr_block
  availability_zone = var.az


  tags = {
    Name        = "${var.subnet_type}-subnet-${var.az}"
    subnet_type = "${var.subnet_type}"
  }
}

output "id" {
  value = aws_subnet.subnet.id
}
