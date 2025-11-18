output "alb_dns_name"{
  value = aws_lb.ALB.dns_name
}
output "nlb_dns_name"{
  value = aws_lb.amqp_nlb.dns_name
}
output "amqp_tg_arn"{
    value = aws_lb_target_group.amqp_tg.arn
}
output "alb_target_group_arn"{
    value = aws_lb_target_group.alb_target_group.arn
}