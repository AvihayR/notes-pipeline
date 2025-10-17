resource "aws_docdb_cluster" "notes_cluster" {
  cluster_identifier      = "notes-docdb-cluster"
  engine                  = "docdb"
  master_username         = var.master_username
  master_password         = var.master_password
  availability_zones      = sort(var.az_list)
  backup_retention_period = 5
  preferred_backup_window = "20:00-22:00"
  skip_final_snapshot     = true
  apply_immediately       = true
  vpc_security_group_ids  = [aws_security_group.docdb_sg.id]
  db_subnet_group_name    = aws_docdb_subnet_group.subnet_group.name

  # Use when in dev env:
  # lifecycle {
  #   prevent_destroy = true
  #   ignore_changes = [
  #     availability_zones,
  #     master_password,
  #     apply_immediately
  #   ]
  # }
}

resource "aws_docdb_cluster_instance" "docdb_instance" {
  cluster_identifier = aws_docdb_cluster.notes_cluster.id
  instance_class     = "db.t3.medium"

  # Use when in dev env:
  # lifecycle {
  #   prevent_destroy = true
  #   ignore_changes = [
  #     availability_zone,
  #     apply_immediately,
  #   ]
  # }

  tags = {
    "Name" = "notes-db"
  }
}

resource "aws_docdb_subnet_group" "subnet_group" {
  name       = "docdb-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "docdb-subnet-group"
  }
}

resource "aws_security_group" "docdb_sg" {
  name        = "docdb-security-group"
  description = "Security group for DocumentDB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }
}

output "url" {
  value = aws_docdb_cluster.notes_cluster.endpoint
}

