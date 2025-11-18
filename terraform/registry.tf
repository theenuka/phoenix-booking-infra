# List of your microservices
variable "service_names" {
  description = "List of microservice names"
  type        = set(string)
  default     = [
    "identity",
    "hotel",
    "booking",
    "search",
    "notification",
    "api-gateway",
    "frontend"
  ]
}

# Create an ECR Repository for each service automatically
resource "aws_ecr_repository" "app_repos" {
  for_each = var.service_names

  name                 = "phoenix-${each.key}-service"
  image_tag_mutability = "MUTABLE"
  force_delete         = true  # Allows deleting repo even if it has images (good for training)

  image_scanning_configuration {
    scan_on_push = true        # Best Practice: Auto-scan for security vulnerabilities
  }

  tags = {
    Name = "phoenix-${each.key}-repo"
  }
}

# Output the repository URLs (We need these for GitHub Actions later)
output "ecr_repo_urls" {
  value = { for k, v in aws_ecr_repository.app_repos : k => v.repository_url }
}