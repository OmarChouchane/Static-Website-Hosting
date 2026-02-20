terraform {
  backend "s3" {
    bucket = "tfstate-2-tier-demo"
    key    = "backend/terraform.tfstate"
    region = "eu-west-1"
  }
}