
resource "aws_launch_template" "API_Launch_Template" {
  name_prefix            = "API_LT_"
  
  image_id               = data.aws_ami.ubuntu_server.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [var.ec2_sg_id]
  iam_instance_profile {
    name = var.rabbit_instance_profile_name
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 8
      volume_type = "gp3"
      encrypted   = true
    }
  }

  # Data volume for RabbitMQ


  user_data = base64encode(file("${path.module}/userdata.sh"))
  
}


####Auto scaling group#####

resource "aws_autoscaling_group" "API_ASG" {
  desired_capacity = 3
  max_size         = 5
  min_size         = 3
  vpc_zone_identifier = [
    var.private_subnet_a_id,
    var.private_subnet_b_id
  ]
  launch_template {
    id      = aws_launch_template.API_Launch_Template.id
    version = "$Latest"
  }
  target_group_arns = [
    var.alb_target_group_arn,
    var.amqp_tg_arn
  ]
  # Do NOT attach the AMQP target group from an ALB. See NLB section below.
  tag {
    key                 = "Name"
    value               = "RabbitNode"
    propagate_at_launch = true
  }
   depends_on = [
    aws_launch_template.API_Launch_Template,
  ]
}




data "aws_ami" "ubuntu_server" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  owners = ["099720109477"] # Canonical
}
