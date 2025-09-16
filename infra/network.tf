
resource "aws_vpc" "vpc_cs1" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "vpc_cs1"
  }
}

resource "aws_subnet" "public_cs1_A" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "public_cs1_A"
  }
}
resource "aws_subnet" "privateweb_cs1_A" {
  vpc_id     = aws_vpc.vpc_cs1.id
  cidr_block = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "privateweb_cs1_A"
  }
}
resource "aws_subnet" "privatedb_cs1_A" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "privatedb_cs1_A"
  }
}
resource "aws_subnet" "public_cs1_B" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.10.0/24"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "public_cs1_B"
  }
}
resource "aws_subnet" "privateweb_cs1_B" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.11.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "privateweb_cs1_B"
  }
}
resource "aws_subnet" "privatedb_cs1_B" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.12.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "privatedb_cs1_B"
  }
}