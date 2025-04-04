output "amazon_linux_ec2_instance_private_ips" {
  description = "Private IP addresses of the Amazon Linux EC2 instances"
  value       = module.amazon_linux_ec2s[*].private_ip
}

output "ubuntu_ec2_instance_private_ips" {
  description = "Private IP addresses of the Ubuntu EC2 instances"
  value       = module.ubuntu_ec2s[*].private_ip
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
