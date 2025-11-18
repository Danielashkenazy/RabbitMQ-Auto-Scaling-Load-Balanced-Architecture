provider "aws" {
  region = "us-east-1"
}
module "vpc" {
  source ="./modules/vpc"
  vpc_cidr = var.vpc_cidr
  public_subnet_az_a = var.public_subnet_az_a
  public_subnet_cidr_a = var.public_subnet_cidr_a
  public_subnet_az_b = var.public_subnet_az_b
  public_subnet_cidr_b = var.public_subnet_cidr_b
  private_subnet_az_a = var.private_subnet_az_a
  private_subnet_cidr_a = var.private_subnet_cidr_a
  private_subnet_az_b = var.private_subnet_az_b
  private_subnet_cidr_b = var.private_subnet_cidr_b
}

module "security_groups" {
  source = "./modules/security_groups"
  vpc_id = module.vpc.vpc_id
  vpc_cidr = var.vpc_cidr
  depends_on = [ module.vpc ]
}

module "secrets" {
  source = "./modules/secrets"
}


module "load_balancers" {
  source = "./modules/loadbalancers"
  vpc_id = module.vpc.vpc_id
  ALB_sg_id = module.security_groups.ALB_sg_id
  public_subnet_a_id = module.vpc.public_subnet_a_id
  public_subnet_b_id =  module.vpc.public_subnet_b_id

}



module "iam"{
  source = "./modules/iam"
  aws_secret_admin_pass_arn = module.secrets.aws_secret_admin_pass_arn
  aws_secret_rabbit_admin_user_arn = module.secrets.aws_secret_rabbit_admin_user_arn
  aws_secret_rabbit_erlang_cookie_arn = module.secrets.aws_secret_rabbit_erlang_cookie_arn
  depends_on = [ module.secrets ]
}

module "compute" {
  source = "./modules/compute"
  private_subnet_a_id = module.vpc.private_subnet_a_id
  private_subnet_b_id = module.vpc.private_subnet_b_id
  amqp_tg_arn = module.load_balancers.amqp_tg_arn
  alb_target_group_arn = module.load_balancers.alb_target_group_arn
  rabbit_instance_profile_name = module.iam.rabbit_instance_profile_name
  ec2_sg_id = module.security_groups.EC2_sg_id
  depends_on = [ module.iam, module.security_groups, module.load_balancers ]
  
}

