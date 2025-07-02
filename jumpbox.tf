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
                curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
                chmod 700 get_helm.sh
                ./get_helm.sh
                /usr/local/bin/aws configure set aws_access_key_id AKIASTQVKHUYCEZLIKVF
                /usr/local/bin/aws configure set aws_secret_access_key 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
                /usr/local/bin/aws set default region eu-north-1
                /usr/local/bin/aws set default output json
                /usr/local/bin/aws eks update-kubeconfig --name test-cluster
                /usr/local/bin/kubectl create namespace argocd
                /usr/local/bin/kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml 
                curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
                sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
                rm argocd-linux-amd64
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