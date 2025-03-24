terraform {
  backend "s3" {
    bucket = "terraform-awsapp-statefile-01"
    key    = "key/terraform-statefile.tflock"
    region = "eu-north-1"
  }
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}

resource "aws_instance" "example" {
  ami = "ami-0c1ac8a41498c1a9c"
  instance_type = "t3.micro"
  
}
