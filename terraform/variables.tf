variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "admin_cidr" {
  description = "CIDR block for admin access to the bastion host"
  type        = string
  default     = "10.0.0.0/16" # PLEASE CHANGE THIS TO YOUR IP ADDRESS

  validation {
    condition     = can(cidrnetmask(var.admin_cidr))
    error_message = "Must be a valid CIDR block."
  }
}
