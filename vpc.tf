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
  cidr_block = "10.0.0.0/25"
  availability_zone = "eu-north-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Main"
  }
}

resource "aws_subnet" "main2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.0.128/25"
  availability_zone = "eu-north-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "Main2"
  }
}

resource "aws_subnet" "backend" {
  vpc_id     = aws_vpc.backend.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Backend"
  }
}

resource "aws_subnet" "data1" {
  vpc_id     = aws_vpc.data.id
  cidr_block = "10.0.2.0/25"
  availability_zone = "eu-north-1a"
  tags = {
    Name = "Data1"
  }
}

resource "aws_subnet" "data2" {
  vpc_id     = aws_vpc.data.id
  cidr_block = "10.0.2.128/25"
  availability_zone = "eu-north-1b"
  tags = {
    Name = "Data2"
  }
}

 resource "aws_db_subnet_group" "data_subnet_group" {
   name = "data1"
   subnet_ids = [aws_subnet.data1.id, aws_subnet.data2.id]

   tags = {
     Name = "Data Subnet Group"
   }
 }

resource "aws_internet_gateway" "mainGateway" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "Main Internet Gateway"
  }
}

resource "aws_route_table" "defaultMain" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mainGateway.id
  }
  depends_on = [aws_internet_gateway.mainGateway]
    tags = {
      Name = "Main Route Table"
    }
}
# resource "aws_route" "mainRoute" {
#    route_table_id = aws_route_table.defaultMain.id
#    destination_cidr_block = "0.0.0.0/0"
#    gateway_id = aws_internet_gateway.mainGateway.id
#    depends_on = [aws_internet_gateway.mainGateway]
# }
resource "aws_main_route_table_association" "main" {
    vpc_id     = aws_vpc.main.id
    route_table_id = aws_route_table.defaultMain.id
    depends_on = [aws_route_table.defaultMain, aws_vpc.main]
  }
resource "aws_internet_gateway" "backendGateway" {
  vpc_id = aws_vpc.backend.id
  tags = {
    Name = "Backend Internet Gateway"
  }
}

resource "aws_eip" "clusterEIP" {
  #vpc = true
  tags = {
    Name = "Cluster NAT EIP"
  }
}

resource "aws_nat_gateway" "clusterNAT" {
  allocation_id = aws_eip.clusterEIP.id
  subnet_id     = aws_subnet.main.id
  tags = {
    Name = "Cluster NAT Gateway"
  }
}


resource "aws_route_table" "defaultBackend" {
  vpc_id = aws_vpc.backend.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.backendGateway.id
    
  }
   depends_on = [aws_internet_gateway.backendGateway ]
  tags = {
    Name = "Backend Route Table"
  }

}

#  resource "aws_route" "backendRoute" {
#    route_table_id = aws_route_table.defaultBackend.id
#    destination_cidr_block = "0.0.0.0/0"
#    gateway_id = aws_internet_gateway.backendGateway.id
#    depends_on = [aws_internet_gateway.backendGateway]

#  }

 resource "aws_main_route_table_association" "backend" {
   vpc_id     = aws_vpc.backend.id
   route_table_id = aws_route_table.defaultBackend.id
   depends_on = [aws_route_table.defaultBackend]
 }

 resource "aws_route_table" "defaultData" {
   vpc_id = aws_vpc.data.id
    route {
      cidr_block = "0.0.0.0/0"
      vpc_peering_connection_id = aws_vpc_peering_connection.main-data-peer.id
    }
    tags = {
      Name = "Data Route Table"
    }
 }

 resource "aws_main_route_table_association" "data" {
   vpc_id     = aws_vpc.data.id
   route_table_id = aws_route_table.defaultData.id
 }
  resource "aws_security_group" "main-securityGroup" {
  description = "HTTP/HTPPS access"
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  
  }
   tags = {
    Name = "Main Security Group"
   }
}
 
resource "aws_vpc_peering_connection" "main-backend-peer" {
  vpc_id      = aws_vpc.main.id
  peer_vpc_id = aws_vpc.backend.id

  auto_accept = true

  tags = {
    Name = "Main-Backend Peering"
  }
}

resource "aws_route" "main-to-backend" {
  route_table_id            = aws_route_table.defaultMain.id
  destination_cidr_block    = aws_vpc.backend.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.main-backend-peer.id
}

resource "aws_route" "backend-to-main" {
  route_table_id            = aws_route_table.defaultBackend.id
  destination_cidr_block    = aws_vpc.main.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.main-backend-peer.id
}

resource "aws_vpc_peering_connection" "main-data-peer" {
  vpc_id      = aws_vpc.main.id
  peer_vpc_id = aws_vpc.data.id

  auto_accept = true

  tags = {
    Name = "Main-Data Peering"
  }
}

 resource "aws_route" "main-to-data" {
   route_table_id            = aws_route_table.defaultMain.id
   destination_cidr_block    = aws_vpc.data.cidr_block
   vpc_peering_connection_id = aws_vpc_peering_connection.main-data-peer.id
 }

 resource "aws_route" "data-to-main" {
   route_table_id            = aws_route_table.defaultData.id
   destination_cidr_block    = aws_vpc.main.cidr_block
   vpc_peering_connection_id = aws_vpc_peering_connection.main-data-peer.id
 }

resource "aws_vpc_peering_connection" "backend-data-peer" {
  vpc_id      = aws_vpc.backend.id
  peer_vpc_id = aws_vpc.data.id

  auto_accept = true

  tags = {
    Name = "Backend-Data Peering"
  }
}
resource "aws_route" "backend-to-data" {
  route_table_id            = aws_route_table.defaultBackend.id
  destination_cidr_block    = aws_vpc.data.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.backend-data-peer.id
}

resource "aws_route" "data-to-backend" {
  route_table_id            = aws_route_table.defaultData.id
  destination_cidr_block    = aws_vpc.backend.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.backend-data-peer.id
}