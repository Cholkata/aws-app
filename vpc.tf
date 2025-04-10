  resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/24"
    
    tags = {
      Name = "Application VPC"
    }
  }
resource "aws_vpc" "backend" {
  cidr_block = "10.0.1.0/24"
  
  tags = {
    Name = "Backend VPC"
  }
}

resource "aws_vpc"  "data" {
    cidr_block = "10.0.2.0/24"

    tags = {
        Name = "Data VPC"
    }
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "Main"
  }
}

resource "aws_subnet" "backend" {
  vpc_id     = aws_vpc.backend.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Backend"
  }
}

resource "aws_subnet" "data" {
  vpc_id     = aws_vpc.data.id
  cidr_block = "10.0.2.0/24"
  #availability_zone = "eu-north-1a"
  tags = {
    Name = "Data"
  }
}

resource "aws_db_subnet_group" "data_subnet_group" {
  name = "data"
  subnet_ids = [aws_subnet.data.id]

  tags = {
    Name = "Data Subnet Group"
  }
}
