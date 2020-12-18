# DB Security Group
resource "aws_security_group" "db_sg" {
  name        = "db_sg"
  description = "Allow db port"
  vpc_id      = aws_vpc.vpc.id
  
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# DB subnet group
resource "aws_db_subnet_group" "db_subnet_grp" {
  name = "db_subnet_grp"
  #count = length(var.subnets_pri)
  subnet_ids = aws_subnet.private.*.id
}


# Database - Postgresql - 2
resource "aws_db_instance" "db1" {
  allocated_storage       = 20
  backup_retention_period = 7
  db_subnet_group_name    = aws_db_subnet_group.db_subnet_grp.name
  # count                   = length(var.subnets_pri)
  engine                  = "postgres"
  engine_version          = "10.14"
  identifier              = "db1"
  instance_class          = "db.t3.small"
  multi_az                = false
  storage_type            = "gp2"
  port                    = 5432
  name                    = "db1"
  username                = "postdb"
  password                = "postdb123"
  skip_final_snapshot     = true
  availability_zone       = "us-east-1a"
}


resource "aws_db_instance" "db2" {
  allocated_storage       = 20
  backup_retention_period = 7
  db_subnet_group_name    = aws_db_subnet_group.db_subnet_grp.name
  # count                   = length(var.subnets_pri)
  engine                  = "postgres"
  engine_version          = "10.14"
  identifier              = "db2"
  instance_class          = "db.t3.small"
  multi_az                = false
  storage_type            = "gp2"
  port                    = 5432
  name                    = "db2"
  username                = "postdb"
  password                = "postdb123"
  skip_final_snapshot     = true
  availability_zone       = "us-east-1b"
}