  resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/24"
    
    tags = {
      Name = "Application VPC"
    }
  }
resource "aws_vpc" "backend" {
  cidr_block = "10.0.1.0/24"
  #main_route_table_id = aws_route_table.defaultBackend.id
  #depends_on = [ aws_main_route_table_association.backend ]
  
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

resource "aws_internet_gateway" "backendGateway" {
  vpc_id = aws_vpc.backend.id
  tags = {
    Name = "Backend Internet Gateway"
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

resource "aws_route" "route" {
  route_table_id = aws_route_table.defaultBackend.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.backendGateway.id
  depends_on = [aws_internet_gateway.backendGateway]

}

 resource "aws_main_route_table_association" "backend" {
   vpc_id     = aws_vpc.backend.id
   route_table_id = aws_route_table.defaultBackend.id
   depends_on = [aws_route_table.defaultBackend]
 }

 
# resource "aws_vpc_peering_connection" "vpcPeering" {
#   vpc_id        = aws_vpc.main.id
#   peer_vpc_id   = aws_vpc.backend.id
#   auto_accept   = true

#   tags = {
#     Name = "VPC Peering Connection"
#   }
# }

# resource "aws_route_table" "defaultMain" {
#   vpc_id = aws_vpc.main.id
#   route {
#     cidr_block = "0.0.0.0/0"
    
#   }
#   tags = {
#     Name = "Backend Route Table"
#   }

# }

# resource "aws_route" "route2" {
#   route_table_id = aws_route_table.defaultMain.id
#   destination_cidr_block = "0.0.0.0/0"
#   transit_gateway_id = aws_vpc.main.id
#   depends_on = [aws_route_table.defaultMain]
# }


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
