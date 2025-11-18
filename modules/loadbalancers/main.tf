#####Application load balancer target group and listener#####

resource "aws_lb_target_group" "alb_target_group" {
  name        = "rabbit-ui-tg"
  port        = 15672
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"
  
  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = "15672"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"  # Expect HTTP 200 OK
  }

  # Allow time for RabbitMQ to start
  deregistration_delay = 30
}


resource "aws_lb" "ALB" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.ALB_sg_id]
  subnets            = [var.public_subnet_a_id, var.public_subnet_b_id]

  depends_on = [
    aws_lb_target_group.alb_target_group,
    aws_lb_target_group.amqp_tg
  ]
}

resource "aws_lb_listener" "ALB-listener" {
  load_balancer_arn = aws_lb.ALB.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}


#####Network load balancer and listener for AMQP traffic#####

resource "aws_lb" "amqp_nlb" {
  name               = "amqp-nlb"
  load_balancer_type = "network"
  subnets            = [var.public_subnet_a_id, var.public_subnet_b_id]
  depends_on = [
    aws_lb_target_group.alb_target_group,
    aws_lb_target_group.amqp_tg
  ]
}

resource "aws_lb_target_group" "amqp_tg" {
  name        = "amqp-tg"
  port        = 5672
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "instance"
  health_check {
    port                = "15672"
    protocol            = "HTTP"
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    timeout             = 5
  }
}

resource "aws_lb_listener" "amqp_listener" {
  load_balancer_arn = aws_lb.amqp_nlb.arn
  port              = 5672
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.amqp_tg.arn
  }
}

