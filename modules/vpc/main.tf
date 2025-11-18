
resource "aws_vpc" "main" {
  cidr_block =var.vpc_cidr
   enable_dns_hostnames = true
  tags = {
    Name = "main_vpc"
  }
}


resource "aws_eip" "nat_GW_eip" {
  domain     = "vpc"
  depends_on = [aws_vpc.main]
}
resource "aws_nat_gateway" "nat_GW" {
  allocation_id = aws_eip.nat_GW_eip.id
  subnet_id     = aws_subnet.public_subnet.id
  depends_on = [
  aws_eip.nat_GW_eip,
  aws_internet_gateway.IGW,
  aws_route_table_association.public_subnet_IGW_association
]

  tags = {
    Name = "nat-gateway"
  }
}


resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr_a
  availability_zone       = var.public_subnet_az_a
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet"
  }
  depends_on = [aws_vpc.main]
}
resource "aws_subnet" "public_subnet2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr_b
  availability_zone       = var.public_subnet_az_b
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet2"
  }
  depends_on = [aws_vpc.main]
}

# Replace AZs to match your provider region
resource "aws_subnet" "private_subnet_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidr_a
  availability_zone       = var.private_subnet_az_a
  map_public_ip_on_launch = false
  tags                    = { Name = "private_subnet_a" }
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidr_b
  availability_zone       = var.private_subnet_az_b
  map_public_ip_on_launch = false
  tags                    = { Name = "private_subnet_b" }
}

resource "aws_route_table_association" "priv_a" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.private_subnet_NatGW_route.id
}

resource "aws_route_table_association" "priv_b" {
  subnet_id      = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.private_subnet_NatGW_route.id
}

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main_igw"
  }
  depends_on = [aws_vpc.main]
}
resource "aws_route_table" "IGW-route" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }
  depends_on = [aws_internet_gateway.IGW]
}
resource "aws_route_table" "private_subnet_NatGW_route" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_GW.id
  }
  depends_on = [aws_nat_gateway.nat_GW]
}

resource "aws_route_table_association" "public_subnet_IGW_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.IGW-route.id
}
resource "aws_route_table_association" "public_subnet2_IGW_association" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.IGW-route.id
}
