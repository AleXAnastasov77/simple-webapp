# ////////////////////// FETCH AMI ID FROM SSM //////////////////////////

data "aws_ssm_parameter" "webserver_ami" {
  name = "/cs1/webserver/ami"
}

# ////////////////////// EC2 LAUNCH TEMPLATE //////////////////////////
resource "aws_launch_template" "cs1_webapp" {
  name_prefix   = "cs1-webapp-"
  image_id      = data.aws_ssm_parameter.webserver_ami.value
  instance_type = "t3.micro"
  iam_instance_profile {
    arn = "arn:aws:iam::057827529833:instance-profile/SSMRole"
  }
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

# ////////////////////// ALB & ASG //////////////////////////

resource "aws_lb_target_group" "lbtg_cs1" {
  name        = "lbtg-cs1"
  target_type = "instance"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc_cs1.id
  health_check {
    path     = "/health"
    protocol = "HTTP"
    port = 5000
    matcher  = "200-399"   # treat any 2xx/3xx as healthy
    interval = 30          # check every 30s
    timeout  = 5           # must respond within 5s
    healthy_threshold   = 3   # need 3 OKs in a row
    unhealthy_threshold = 2   # 2 fails = unhealthy
  }
}

resource "aws_lb" "alb_cs1" {
  name               = "alb-cs1"
  load_balancer_type = "application"
  subnets            = [aws_subnet.public_cs1_A.id, aws_subnet.public_cs1_B.id]
  security_groups = [aws_security_group.app_sg.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb_cs1.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lbtg_cs1.arn
  }
}

resource "aws_autoscaling_group" "bar" {
  vpc_zone_identifier       = [aws_subnet.privateweb_cs1_A.id, aws_subnet.privateweb_cs1_B.id]
  desired_capacity          = 2
  max_size                  = 2
  min_size                  = 1
  target_group_arns         = [aws_lb_target_group.lbtg_cs1.arn]
  termination_policies      = ["OldestInstance"]
  health_check_type         = "ELB"
  health_check_grace_period = 300
  launch_template {
    id      = aws_launch_template.cs1_webapp.id
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value               = "cs1-webserver"
    propagate_at_launch = true
  }
}