output "neptune_cluster_endpoint" {
  value = aws_neptune_cluster.my-neptune-cluster.endpoint
}

output "SSH-tunneling-Command" {
  value = "ssh -vNT4 -o StrictHostKeyChecking=no -L8182:${aws_neptune_cluster.my-neptune-cluster.endpoint}:8182 ec2-user@${aws_instance.ec2-neptune-gw.public_ip}"
}
