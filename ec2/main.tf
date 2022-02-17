resource "aws_security_group" "instance_sg" {
    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["${chomp(data.http.myPublicIpv4.body)}/32"]
    }
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }
}


data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners = ["amazon"]

  filter {
   name   = "name"
   values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_key_pair" "sshKey" {
  key_name_prefix = "mykey-"
  public_key = file(var.public_key)
}

resource "aws_instance" "myInstance" {
  ami           = data.aws_ami.amazon-linux-2.id
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  key_name = aws_key_pair.sshKey.key_name
}

output "Connexion" {
  value = "ssh -o StrictHostKeyChecking=no ec2-user@${aws_instance.myInstance.public_dns}"
}

output "SSH_Config" {
  value = <<SSHCONFIG

  echo "Host ec2-${aws_instance.myInstance.instance_type}
    User          ec2-user
    Hostname      ${aws_instance.myInstance.public_dns}
    StrictHostKeyChecking no" >> ~/.ssh/config

    SSHCONFIG
}
