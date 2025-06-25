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

    user_data = <<-EOF
                #!/bin/bash
                /usr/bin/apt-get update
                /usr/bin/apt-get upgrade -y
                /usr/bin/apt-get upgrade linux-aws
                /usr/bin/apt-get install net-tools
                /usr/bin/apt install unzip
                /usr/bin/curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
                /usr/bin/unzip awscliv2.zip
                sudo ./aws/install
                /usr/bin/curl -LO https://dl.k8s.io/release/v1.33.0/bin/linux/amd64/kubectl
                sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
                curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"
                sudo mv /tmp/eksctl /usr/local/bin
                EOF


    tags = {
        Name = "Jumpbox Instance"
    }
}

resource "aws_eip" "jump" {
   instance = aws_instance.jumpbox.id
   #vpc = true

   tags = {
     Name = "Jumpbox EIP"
   } 
}

resource "aws_ecr_repository" "ECR" {
  name = "jumpbox-repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Name = "Jumpbox ECR Repository"
  }
  
}