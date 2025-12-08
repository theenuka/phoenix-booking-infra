variable "aws_region" {
  description = "AWS region to deploy resources"
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name prefix for tags"
  default     = "phoenix"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the public subnet"
  default     = "10.0.1.0/24"
}

variable "admin_cidr" {
  description = "CIDR block allowed to access SSH and K8s API (e.g., your home IP)"
  default     = "0.0.0.0/0" # CHANGE THIS to your IP for security!
}