#db_subnet_group
resource "aws_db_subnet_group" "postgresql_subnet" {
  name       = "dp-insight-subnet-group"
  subnet_ids = var.subnet_ids

}

#db_parameter_group

resource "aws_db_parameter_group" "postgresql_parameter" {
  name   = "dp-insight-parameter-group"
  family = var.family
  
}

#db security group

resource "aws_security_group" "db_security_group" {
  name        = "${var.name}-db"
  vpc_id      = var.vpc_id

  ingress {
    description = "ssh"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dp_insight_db"
  }
}

#db instance

resource "aws_db_instance" "default" {
  identifier = var.identifier
  allocated_storage    = var.allocated_storage
  storage_type         = var.storage_type
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  vpc_security_group_ids = [aws_security_group.db_security_group.id]
  db_subnet_group_name=aws_db_subnet_group.postgresql_subnet.name
  name                 = var.dbname
  username             = var.username
  password             = var.password
  parameter_group_name = aws_db_parameter_group.postgresql_parameter.name
  skip_final_snapshot  = true
}