resource "aws_security_group" "jump" {
  description = "Allow SSH access"
  vpc_id = aws_vpc.backend.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
   tags = {
    Name = "Jumpbox Security Group"
   }
}

resource "aws_instance" "jumpbox" {
    ami = "ami-0c1ac8a41498c1a9c"
    instance_type = "t3.micro"
    subnet_id = aws_subnet.backend.id
    vpc_security_group_ids = [aws_security_group.jump.id]
    associate_public_ip_address = true
    
    root_block_device {
      volume_size = 20
    }


    tags = {
        Name = "Jumpbox Instance"
    }
}

resource "aws_eip" "jump" {
  instance = aws_instance.jumpbox.id
  vpc = true

  tags = {
    Name = "Jumpbox EIP"
  } 
}