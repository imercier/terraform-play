data "http" "myPublicIpv4" {
  url = "http://ipv4.icanhazip.com"
}

data "aws_vpc" "default" {
  default = true
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_security_group" "sg-rds" {
  vpc_id      = "${data.aws_vpc.default.id}"
ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myPublicIpv4.body)}/32"]
  }
}
resource "aws_db_instance" "mi_rds_pg" {
  instance_class         = "db.t3.micro"
  db_name                = "mydb"
  allocated_storage      = 5
  engine                 = "postgres"
  skip_final_snapshot    = true
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.sg-rds.id]
  apply_immediately      = true
  username               = "dba"
  password               = random_password.password.result
}

output "password" {
  value     = random_password.password.result
  sensitive = true
}

output "password_decode" {
  value       = "terraform output -json | jq -r '.password.value'"
}

output "connect" {
  value     = "psql --host=${aws_db_instance.mi_rds_pg.address} --username=${aws_db_instance.mi_rds_pg.username} --password --dbname=${aws_db_instance.mi_rds_pg.name}"
}
