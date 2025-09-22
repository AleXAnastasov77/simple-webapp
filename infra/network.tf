
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
resource "aws_subnet" "privatemonitoring_cs1_B" {
  vpc_id            = aws_vpc.vpc_cs1.id
  cidr_block        = "10.0.13.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "privatemonitoring_cs1_B"
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
resource "aws_route_table_association" "g" {
  subnet_id      = aws_subnet.privatemonitoring_cs1_B.id
  route_table_id = aws_route_table.rt_private_cs1.id
}

# ////////////////////// SECURITY GROUPS //////////////////////////

resource "aws_security_group" "app_sg" {
  name        = "app-sg"
  description = "Allow inbound HTTP/HTTPS for app servers"
  vpc_id      = aws_vpc.vpc_cs1.id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow HTTP"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "app-sg"
  }
}
resource "aws_security_group" "monitoring_sg" {
  name        = "monitoring-sg"
  description = "Security rules for the monitoring system."
  vpc_id      = aws_vpc.vpc_cs1.id

  ingress {
    description = "Allow Prometheus"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }
  ingress {
    description = "Allow Grafana"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow Loki"
    from_port   = 3100
    to_port     = 3100
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }
  ingress {
    description = "Allow Alertmanager"
    from_port   = 9093
    to_port     = 9093
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "monitoring-sg"
  }
}


resource "aws_security_group" "db_sg" {
  name        = "db-sg"
  description = "Allow MySQL only from app SG"
  vpc_id      = aws_vpc.vpc_cs1.id

  ingress {
    description     = "Allow MySQL from app servers"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "db-sg"
  }
}

# ////////////////////// VPN //////////////////////////
data "aws_acm_certificate" "cert" {
  domain   = "server.vpn.internal"
  statuses = ["ISSUED"]
}

resource "aws_ec2_client_vpn_endpoint" "vpnendpoint_cs1" {
  description            = "VPN for monitoring access"
  server_certificate_arn = data.aws_acm_certificate.cert.arn
  client_cidr_block      = "10.100.0.0/16"
  dns_servers = ["10.0.0.2"]
  vpc_id = aws_vpc.vpc_cs1.id
  split_tunnel = true

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = "arn:aws:acm:eu-central-1:057827529833:certificate/54ab3b77-0344-4156-9c8b-620156c5e2d4"
  }

  connection_log_options {
    enabled               = false
  }
}

resource "aws_ec2_client_vpn_network_association" "network_association" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpnendpoint_cs1.id
  subnet_id              = aws_subnet.privatemonitoring_cs1_B.id
}

resource "aws_ec2_client_vpn_authorization_rule" "authorization_rule" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpnendpoint_cs1.id
  target_network_cidr    = aws_subnet.privatemonitoring_cs1_B.cidr_block
  authorize_all_groups   = true
}