terraform {
  backend "s3" {
    bucket         = "phoenix-booking-terraform-state"
    key            = "phoenix-booking/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "phoenix-booking-terraform-lock"
    encrypt        = true
  }
}
