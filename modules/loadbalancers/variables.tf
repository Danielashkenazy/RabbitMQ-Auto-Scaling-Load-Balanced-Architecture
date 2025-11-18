
variable "vpc_id" {
  description = "The ID of the VPC where the load balancers will be deployed"
  type        = string
}


variable "ALB_sg_id" {
  description = "security group ID for ALB"
}
variable "public_subnet_a_id" {
  description = "The ID of the first public subnet"
  type        = string
}
variable "public_subnet_b_id" {
  description = "The ID of the second public subnet"
  type        = string
}

