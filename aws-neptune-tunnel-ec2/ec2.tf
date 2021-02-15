resource "aws_key_pair" "mykey" {
  public_key = file(var.public_key_path)
  key_name   = "mykey"
}

data "aws_ami" "amazon-linux-last" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_instance" "ec2-neptune-gw" {
  instance_type          = var.ec2_type
  ami                    = data.aws_ami.amazon-linux-last.id
  key_name               = aws_key_pair.mykey.key_name
  vpc_security_group_ids = [aws_security_group.my-sg.id]
  subnet_id              = aws_subnet.mysubnet-a.id
}
