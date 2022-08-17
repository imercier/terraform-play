data "http" "myPublicIpv4" {
  url = "http://ipv4.icanhazip.com"
}

variable "public_key" {
  type        = string
  default     = "~/.ssh/id_rsa_ec2_win.pub"
}

resource "aws_key_pair" "sshKey" {
  key_name_prefix = "mywinkey-"
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
        from_port   = 3389
        to_port     = 3389
        protocol    = "tcp"
        cidr_blocks = ["${chomp(data.http.myPublicIpv4.body)}/32"]
    }
}

resource "aws_instance" "myInstance" {
  ami           = "ami-0bdccab4f28cb48db" # Microsoft Windows Server 2019
  instance_type = "m5.large"
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  key_name = aws_key_pair.sshKey.key_name
  get_password_data = true

  root_block_device {
      encrypted   = true
      volume_type = "gp3"
      volume_size = "30"
      delete_on_termination = true
    }
}

resource "aws_eip" "staticip" {
  instance = aws_instance.myInstance.id
}

output "rdp" {
  value = "xfreerdp /size:1920x1080 /bpp:32 /gfx +aero +fonts -u:Administrator -p:'${rsadecrypt(aws_instance.myInstance.password_data, file("~/.ssh/id_rsa_ec2_win"))}' -v:${aws_eip.staticip.public_ip} /cert-ignore"
}

output "start" {
  value = "aws ec2 start-instances --instance-ids ${aws_instance.myInstance.id}"
}

output "stop" {
  value = "aws ec2 stop-instances --instance-ids ${aws_instance.myInstance.id}"
}
