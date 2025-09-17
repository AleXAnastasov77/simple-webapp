resource "aws_servicecatalogappregistry_application" "cs1_web_app" {
  provider    = aws.application
  name        = "CS1WebApp"
  description = "Case Study 1 Web application"
}

provider "aws" {
  default_tags {
    tags = merge(
      var.tags,
      aws_servicecatalogappregistry_application.cs1_web_app.application_tag
    )
  }
}


# ////////////////////// DATABASE //////////////////////////
resource "aws_db_subnet_group" "db_subnetgroup_cs1" {
  name       = "db_subnetgroup_cs1"
  subnet_ids = [aws_subnet.privatedb_cs1_A.id, aws_subnet.privatedb_cs1_B.id]

  tags = {
    Name = "db_subnetgroup_cs1"
  }
}

resource "aws_db_instance" "webapp_mysqldb_cs1" {
  allocated_storage         = 20
  max_allocated_storage     = 25
  db_subnet_group_name      = aws_db_subnet_group.db_subnetgroup_cs1.name
  engine                    = "mysql"
  engine_version            = "8.0"
  instance_class            = "db.t3.micro"
  username                  = var.db_username
  password                  = var.db_password
  parameter_group_name      = "default.mysql8.0"
  skip_final_snapshot       = false
  final_snapshot_identifier = "webapp-mysqldb-final-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  multi_az                  = true
  storage_type              = "gp2"
  vpc_security_group_ids    = [aws_security_group.db_sg.id]
}
