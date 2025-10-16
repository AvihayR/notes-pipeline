resource "aws_route_table" "public_rt" {
  vpc_id = var.vpc_id

  tags = {
    Name = "Public-Route-Table"
  }

  route {
    cidr_block = var.local_cidr
    gateway_id = "local"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.igw_id
  }
}

resource "aws_route_table_association" "public_rt-association" {
  subnet_id      = var.public_subnet_id
  route_table_id = aws_route_table.public_rt.id
}
