data "aws_ami" "ubuntu" {
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

resource "aws_instance" "monitoring_ec2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"
  iam_instance_profile = "SSMRole"
  subnet_id = aws_subnet.privatemonitoring_cs1_B.id
  security_groups = [aws_security_group.monitoring_sg.id]
  root_block_device {
    delete_on_termination = false
    volume_size = 25
    volume_type = "gp3"
  }
  tags = {
    Name = "monitoring_cs1"
  }
}