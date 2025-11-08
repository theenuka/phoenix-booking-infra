terraform {
  backend "s3" {
    
    bucket         = "phoenix-terraform-state-theenuka"
    key            = "phoenix/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "phoenix-terraform-lock"
    encrypt        = true
  }
}