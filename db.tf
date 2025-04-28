
resource "aws_security_group" "rds_security" {
  name = "rds_security_group"
  vpc_id = aws_vpc.data.id
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    tags = {
        Name = "RDS Security Group"
    }
}


resource "aws_db_parameter_group" "db_parameter" {
  name   = "db-param"
  family = "postgres17"

  parameter {
    name  = "log_connections"
    value = "1"
  }
}


  resource "aws_db_instance" "db_instance" {
    identifier = "data"
    instance_class = "db.t3.micro"
    allocated_storage = 20
    engine = "postgres"
    engine_version = "17.4"
    username = "dataadmin"
    password = "Admin123456!"
    db_subnet_group_name = aws_db_subnet_group.data_subnet_group.name
    vpc_security_group_ids = [aws_security_group.rds_security.id]
    parameter_group_name = aws_db_parameter_group.db_parameter.name
    publicly_accessible = false
    skip_final_snapshot = true
  }