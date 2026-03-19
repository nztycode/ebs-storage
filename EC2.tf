locals {
  name_prefix = "nas"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_security_group" "ssh_example" {
  name        = "${local.name_prefix}-sg-ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = "vpc-090af0a798261bc4c"

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-sg-ssh"
  }
}
# EC2 Instance
resource "aws_instance" "example" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t2.micro"
  subnet_id                   = "subnet-0cfdd02118ca6c5a1"
  associate_public_ip_address = true

  key_name               = "nas-key-pair"
  vpc_security_group_ids = [aws_security_group.ssh_example.id]

  tags = {
    Name = "${local.name_prefix}-ec2-example"
  }
}