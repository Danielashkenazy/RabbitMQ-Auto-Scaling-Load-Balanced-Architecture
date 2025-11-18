
variable "private_subnet_a_id" {
  description = "the ID of the first private subnet"
  type        = string
}
variable "private_subnet_b_id" {
  description = "the ID of the second private subnet"
  type        = string
}
variable "alb_target_group_arn" {
  description = "ARN of the main target group"
    type        = string
}
variable "amqp_tg_arn" {
  description = "ARN of the AMQP target group"
    type        = string
}
variable "ec2_sg_id" {
    description = "security group ID for EC2 instances"
    type        = string
}
variable "rabbit_instance_profile_name" {
    description = "IAM instance profile name for RabbitMQ EC2 instances"
    type        = string
}

