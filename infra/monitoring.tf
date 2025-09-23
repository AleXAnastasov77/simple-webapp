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
data "aws_ami" "monitoring" {
  most_recent = true
  owners      = ["057827529833"] # your AWS account ID

  filter {
    name   = "image-id"
    values = ["ami-09e2fe96ff47485e4"]
  }
}

resource "aws_instance" "monitoring_ec2" {
  ami           = data.aws_ami.monitoring.id
  instance_type = "t3.small"
  iam_instance_profile = "MonitoringRole"
  subnet_id = aws_subnet.privatemonitoring_cs1_B.id
  vpc_security_group_ids = [aws_security_group.monitoring_sg.id]
  key_name = "ansible-keypair"
  private_ip = "10.0.13.247"
  root_block_device {
    delete_on_termination = false
    volume_size = 25
    volume_type = "gp3"
  }
  tags = {
    Name = "monitoring_cs1"
  }
}