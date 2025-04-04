output "worker_instance_private_ips" {
  description = "Private IP addresses of the worker EC2 instances"
  value       = module.workers[*].private_ip
}

output "manager_instance_private_ips" {
  description = "Private IP addresses of the manager EC2 instances"
  value       = module.managers[*].private_ip
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_public_subnets" {
  description = "List of IDs of the VPC's public subnets"
  value       = module.vpc.public_subnets
}

output "vpc_private_subnets" {
  description = "List of IDs of the VPC's private subnets"
  value       = module.vpc.private_subnets
}
