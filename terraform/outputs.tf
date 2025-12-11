output "bastion_public_ip" {
  description = "Public IP address of the bastion host"
  value       = aws_instance.bastion.public_ip
}

output "k8s_master_private_ip" {
  description = "Private IP address of the Kubernetes master node"
  value       = aws_instance.k8s_master.private_ip
}

output "k8s_worker_private_ips" {
  description = "Private IP addresses of the Kubernetes worker nodes"
  value       = [for instance in aws_instance.k8s_worker : instance.private_ip]
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnets
}
