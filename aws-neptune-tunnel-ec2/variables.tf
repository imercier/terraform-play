variable "neptune_name" {
  default = "neptune-cluster-db"
}

variable "neptune_engine" {
  default = "neptune"
}

variable "neptune_count" {
  default = 1
}

variable "neptune_class" {
  default = "db.t3.medium"
}

variable "public_key_path" {
  default = "~/.ssh/id_rsa.pub"
}

data "aws_availability_zones" "available" {}

data "http" "workstation-external-ip" {
  url = "http://ipv4.icanhazip.com"
}

locals {
  workstation-external-cidr = "${chomp(data.http.workstation-external-ip.body)}/32"
}

variable "ec2_type" {
  default = "t2.micro"
}
