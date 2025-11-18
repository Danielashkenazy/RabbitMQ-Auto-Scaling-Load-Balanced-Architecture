output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = module.load_balancers.alb_dns_name
}
output "nlb_dns_name" {
  description = "The DNS name of the Network Load Balancer"
  value       = module.load_balancers.nlb_dns_name
}