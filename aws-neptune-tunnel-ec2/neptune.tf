resource "aws_neptune_subnet_group" "neptune-subnet-group" {
  subnet_ids = [aws_subnet.mysubnet-a.id, aws_subnet.mysubnet-b.id]
}

resource "aws_neptune_cluster" "my-neptune-cluster" {
  cluster_identifier                  = var.neptune_name
  engine                              = var.neptune_engine
  skip_final_snapshot                 = true
  iam_database_authentication_enabled = false
  apply_immediately                   = true
  vpc_security_group_ids              = [aws_security_group.my-sg.id]
  neptune_subnet_group_name           = aws_neptune_subnet_group.neptune-subnet-group.name
}

resource "aws_neptune_cluster_instance" "my-neptune-instance" {
  count                     = var.neptune_count
  cluster_identifier        = aws_neptune_cluster.my-neptune-cluster.id
  engine                    = var.neptune_engine
  instance_class            = var.neptune_class
  apply_immediately         = true
  neptune_subnet_group_name = aws_neptune_subnet_group.neptune-subnet-group.name
}
