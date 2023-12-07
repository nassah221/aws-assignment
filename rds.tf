resource "aws_db_instance" "app_db" {
  depends_on                  = ["aws_security_group.rds_sg"]
  identifier                  = var.identifier
  allocated_storage           = var.storage
  engine                      = var.engine
  engine_version              = lookup(var.engine_version, var.engine)
  instance_class              = var.instance_class
  db_name                     = var.db_name
  username                    = var.username
  password                    = var.db_password
  vpc_security_group_ids      = ["${aws_security_group.rds_sg.id}"]
  db_subnet_group_name        = aws_db_subnet_group.default.id
  skip_final_snapshot         = "true"
  publicly_accessible         = "true"
  allow_major_version_upgrade = "true"
}

resource "aws_db_subnet_group" "default" {
  name        = "main_subnet_group"
  description = "Main subnet group"
  subnet_ids  = ["${aws_subnet.subnet_1.id}"]
}


resource "aws_subnet" "subnet_1" {
  vpc_id            = aws_vpc.test0-vpc.id
  cidr_block        = var.subnet_1_cidr
  availability_zone = var.az_1

  tags = {
    Name = "main_subnet1"
  }
}
