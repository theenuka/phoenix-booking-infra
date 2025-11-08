output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "security_group_id" {
  value = aws_security_group.k8s_sg.id
}

output "master_ip" {
  value = aws_instance.k8s_master.public_ip
}

output "worker_ips" {
  value = aws_instance.k8s_worker[*].public_ip
}