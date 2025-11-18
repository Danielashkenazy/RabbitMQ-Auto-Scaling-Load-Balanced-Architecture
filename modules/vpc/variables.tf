variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
    type        = string
}
variable "public_subnet_az_a" {
  description = "The availability zone for the first public subnet"
  type        = string
}
variable "public_subnet_cidr_a" {
  description = "The CIDR block for the first public subnet"
  type        = string
}
variable "public_subnet_az_b" {
  description = "The availability zone for the second public subnet"
  type        = string
}
variable "public_subnet_cidr_b" {
  description = "The CIDR block for the second public subnet"
  type        = string
}
variable "private_subnet_az_a" {
  description = "The availability zone for the first private subnet"
  type        = string
}
variable "private_subnet_cidr_a" {
  description = "The CIDR block for the first private subnet"
  type        = string
}
variable "private_subnet_az_b" {
  description = "The availability zone for the second private subnet"
  type        = string
}
variable "private_subnet_cidr_b" {
  description = "The CIDR block for the second private subnet"
  type        = string
}
