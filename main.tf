terraform {
  backend "s3" {
    bucket = "terraform-awsapp-statefile-02"
    key    = "key/terraform.tfstate"
    region = "eu-north-1"
  }
}
provider "aws" {
  region = "eu-north-1"
}
