# ////////////////////// FETCH AMI ID FROM SSM //////////////////////////

data "aws_ssm_parameter" "webserver_ami" {
  name = "/cs1/webserver/ami"
}

# ////////////////////// EC2 LAUNCH TEMPLATE //////////////////////////
resource "aws_launch_template" "cs1_webapp" {
  name_prefix   = "cs1-webapp-"
  image_id      = data.aws_ssm_parameter.webserver_ami.value
  instance_type = "t3.micro"
  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 8
      volume_type = "gp3"
    }
  }
  network_interfaces {
    security_groups = [aws_security_group.app_sg.id]
  }

  user_data = base64encode(file("user_data.sh"))
}
