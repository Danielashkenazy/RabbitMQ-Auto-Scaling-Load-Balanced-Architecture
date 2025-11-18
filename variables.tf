variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
    type        = string
    default     = "10.10.0.0/16"
}
variable "public_subnet_az_a" {
  description = "The availability zone for the first public subnet"
  type        = string
  default     = "us-east-1a"
}
variable "public_subnet_cidr_a" {
  description = "The CIDR block for the first public subnet"
  type        = string
    default     = "10.10.1.0/24"
}
variable "public_subnet_az_b" {
  description = "The availability zone for the second public subnet"
  type        = string
    default     = "us-east-1b"
}
variable "public_subnet_cidr_b" {
  description = "The CIDR block for the second public subnet"
  type        = string
    default     = "10.10.2.0/24"
}
variable "private_subnet_az_a" {
  description = "The availability zone for the first private subnet"
  type        = string
    default     = "us-east-1a"
}
variable "private_subnet_cidr_a" {
  description = "The CIDR block for the first private subnet"
  type        = string
    default     = "10.10.3.0/24"
}
variable "private_subnet_az_b" {
  description = "The availability zone for the second private subnet"
  type        = string
    default     = "us-east-1b"
}
variable "private_subnet_cidr_b" {
  description = "The CIDR block for the second private subnet"
  type        = string
    default     = "10.10.4.0/24"
}
