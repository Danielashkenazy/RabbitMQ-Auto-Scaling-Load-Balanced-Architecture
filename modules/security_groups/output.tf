
output "ALB_sg_id" {
  value = aws_security_group.ALB_sg.id
}
output "EC2_sg_id" {
  value = aws_security_group.EC2_sg.id
}