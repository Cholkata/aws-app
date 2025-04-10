terraform {
  backend "s3" {
    bucket = "terraform-awsapp-statefile-01"
    key    = "key/terraform-statefile.tflock"
    region = "eu-north-1"
  }
}
provider "aws" {
  region = "eu-north-1"
}
