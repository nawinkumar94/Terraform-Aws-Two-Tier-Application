terraform {
  backend "s3" {
    bucket  = "terraform-state-nv-7777"
    key     = "terraform.tfstate"
    region  = "ap-south-1"
    encrypt = true
  }
}