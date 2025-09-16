
resource "aws_vpc" "vpc_cs1" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "vpc_cs1"
  }
}
# ////////////////////// SUBNETS //////////////////////////
resource "aws_subnet" "public_cs1_A" {
  vpc_id                  = aws_vpc.vpc_cs1.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "public_cs1_A"
  }
}
resource "aws_subnet" "privateweb_cs1_A" {
  vpc_id            = aws_vpc.vpc_cs1.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "privateweb_cs1_A"
  }
}
resource "aws_subnet" "privatedb_cs1_A" {
  vpc_id            = aws_vpc.vpc_cs1.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "privatedb_cs1_A"
  }
}
resource "aws_subnet" "public_cs1_B" {
  vpc_id                  = aws_vpc.vpc_cs1.id
  cidr_block              = "10.0.10.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "public_cs1_B"
  }
}
resource "aws_subnet" "privateweb_cs1_B" {
  vpc_id            = aws_vpc.vpc_cs1.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "privateweb_cs1_B"
  }
}
resource "aws_subnet" "privatedb_cs1_B" {
  vpc_id            = aws_vpc.vpc_cs1.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "privatedb_cs1_B"
  }
}


# ////////////////////// GATEWAYS //////////////////////////
resource "aws_internet_gateway" "igw_cs1" {
  vpc_id = aws_vpc.vpc_cs1.id

  tags = {
    Name = "igw_cs1"
  }
}
# Allocate an Elastic IP for the NAT gateway
resource "aws_eip" "eip_natgw" {
  domain = "vpc"

  tags = {
    Name = "eip_natgw"
  }
}
resource "aws_nat_gateway" "natgw_cs1" {
  subnet_id     = aws_subnet.public_cs1_A.id
  allocation_id = aws_eip.eip_natgw.id
  tags = {
    Name = "natgw_cs1"
  }
  depends_on = [aws_internet_gateway.igw_cs1]
}

# ////////////////////// ROUTE TABLES //////////////////////////

resource "aws_route_table" "rt_public_cs1" {
  vpc_id = aws_vpc.vpc_cs1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_cs1.id
  }
  tags = {
    Name = "rt_public_cs1"
  }
}

resource "aws_route_table" "rt_private_cs1" {
  vpc_id = aws_vpc.vpc_cs1.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw_cs1.id
  }
  tags = {
    Name = "rt_private_cs1"
  }
}

# ////////////////////// ROUTE TABLE ASSOCIATIONS //////////////////////////

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_cs1_A.id
  route_table_id = aws_route_table.rt_public_cs1.id
}
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.public_cs1_B.id
  route_table_id = aws_route_table.rt_public_cs1.id
}
resource "aws_route_table_association" "c" {
  subnet_id      = aws_subnet.privatedb_cs1_A.id
  route_table_id = aws_route_table.rt_private_cs1.id
}
resource "aws_route_table_association" "d" {
  subnet_id      = aws_subnet.privatedb_cs1_B.id
  route_table_id = aws_route_table.rt_private_cs1.id
}
resource "aws_route_table_association" "e" {
  subnet_id      = aws_subnet.privateweb_cs1_A.id
  route_table_id = aws_route_table.rt_private_cs1.id
}
resource "aws_route_table_association" "f" {
  subnet_id      = aws_subnet.privateweb_cs1_B.id
  route_table_id = aws_route_table.rt_private_cs1.id
}

