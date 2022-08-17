data "http" "myPublicIpv4" {
  url = "http://ipv4.icanhazip.com"
}

variable "public_key" {
  type        = string
  description = "File path of public key."
  default     = "~/.ssh/id_rsa.pub"
}

resource "aws_key_pair" "sshKey" {
  key_name_prefix = "mykey-"
  public_key = file(var.public_key)
}

resource "aws_security_group" "instance_sg" {
    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["${chomp(data.http.myPublicIpv4.body)}/32"]
    }
}

data "aws_ami" "myami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "myInstance" {
  ami           = data.aws_ami.myami.id
  instance_type = "m5.large"
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  key_name = aws_key_pair.sshKey.key_name
	user_data = <<EOF
#!/bin/bash
sudo sed -i "s/#Port 22/Port 443/" /etc/ssh/sshd_config
sudo service sshd restart
sudo apt-get -qy purge ufw 
sudo iptables -X
sudo iptables -t nat -F
sudo iptables -t nat -X
sudo iptables -t mangle -F
sudo iptables -t mangle -X
sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -P OUTPUT ACCEPT
EOF

root_block_device {
    encrypted   = true
    volume_type = "gp3" # SSD
    volume_size = "30"
    delete_on_termination = true
  }
}

resource "aws_eip" "staticip" {
  instance = aws_instance.myInstance.id
}

output "Connexion" {
  value = "ssh -p443 ubuntu@${aws_eip.staticip.public_ip}"
}

output "start" {
  value = "aws ec2 start-instances --instance-ids ${aws_instance.myInstance.id}"
}

output "stop" {
  value = "aws ec2 stop-instances --instance-ids ${aws_instance.myInstance.id}"
}
