#vpc
resource "aws_vpc" "main_vpc" {
  cidr_block           = var.CIDR_BLOCK_16
  instance_tenancy     = "default"
  enable_dns_support   = "false"
  enable_dns_hostnames = "false"
  enable_classiclink   = "false"

  tags = {
    Name = "main_vpc"
  }
}
#subnet
resource "aws_subnet" "main_subnet_public_id_1" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.AWS_REGION}a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "MainSubnetPubicId_1"
  }
}
resource "aws_subnet" "main_subnet_public_id_2" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.AWS_REGION}b"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "MainSubnetPubicId_2"
  }
}
resource "aws_subnet" "main_subnet_public_id_3" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "${var.AWS_REGION}c"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "MainSubnetPubicId_3"
  }
}
resource "aws_subnet" "main_subnet_private_id_1" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "${var.AWS_REGION}a"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "MainSubnetPrivateId_1"
  }
}
resource "aws_subnet" "main_subnet_private_id_2" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.5.0/24"
  availability_zone       = "${var.AWS_REGION}b"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "MainSubnetPrivateId_2"
  }
}
resource "aws_subnet" "main_subnet_private_id_3" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.6.0/24"
  availability_zone       = "${var.AWS_REGION}c"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "MainSubnetPrivateId_3"
  }
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "MainInterneGateway"
  }
}
resource "aws_route_table" "main_public" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = var.CIDR_BLOCK_0
    gateway_id = aws_internet_gateway.gw.id
  }
}
resource "aws_route_table_association" "route_a" {
  subnet_id      = aws_subnet.main_subnet_public_id_1.id
  route_table_id = aws_route_table.main_public.id
}
resource "aws_route_table_association" "route_b" {
  subnet_id      = aws_subnet.main_subnet_public_id_2.id
  route_table_id = aws_route_table.main_public.id
}
resource "aws_route_table_association" "route_c" {
  subnet_id      = aws_subnet.main_subnet_public_id_3.id
  route_table_id = aws_route_table.main_public.id
}

# nat gw
resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.nat.id
  subnet_id = aws_subnet.main_subnet_public_id_1.id

  tags = {
    Name = "gw NAT"
  }
}

resource "aws_route_table" "main-private" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = var.CIDR_BLOCK_0
    nat_gateway_id = aws_nat_gateway.nat-gw.id
  }
  tags = {
    Name = "main-private"
  }
}

resource "aws_route_table_association" "route_private_a" {
  subnet_id      = aws_subnet.main_subnet_private_id_1.id
  route_table_id = aws_route_table.main-private.id
}
resource "aws_route_table_association" "route_private_b" {
  subnet_id      = aws_subnet.main_subnet_private_id_2.id
  route_table_id = aws_route_table.main-private.id
}
resource "aws_route_table_association" "route_private_c" {
  subnet_id      = aws_subnet.main_subnet_private_id_3.id
  route_table_id = aws_route_table.main-private.id
}
