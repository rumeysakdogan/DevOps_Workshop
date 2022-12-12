resource "aws_vpc" "dove" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  tags = {
    Name = "vprofile"
  }
}


resource "aws_subnet" "dov-pub-1" {
  vpc_id                  = aws_vpc.dove.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = var.ZONE1
  tags = {
    Name = "dov-pub-1"
  }
}

resource "aws_subnet" "dov-pub-2" {
  vpc_id                  = aws_vpc.dove.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = var.ZONE2
  tags = {
    Name = "dov-pub-2"
  }
}

resource "aws_subnet" "dov-pub-3" {
  vpc_id                  = aws_vpc.dove.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = true
  availability_zone       = var.ZONE3
  tags = {
    Name = "dov-pub-3"
  }
}

resource "aws_subnet" "dov-priv-1" {
  vpc_id                  = aws_vpc.dove.id
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = true
  availability_zone       = var.ZONE1
  tags = {
    Name = "dov-priv-1"
  }
}

resource "aws_subnet" "dov-priv-2" {
  vpc_id                  = aws_vpc.dove.id
  cidr_block              = "10.0.5.0/24"
  map_public_ip_on_launch = true
  availability_zone       = var.ZONE2
  tags = {
    Name = "dov-priv-2"
  }
}

resource "aws_subnet" "dov-priv-3" {
  vpc_id                  = aws_vpc.dove.id
  cidr_block              = "10.0.6.0/24"
  map_public_ip_on_launch = true
  availability_zone       = var.ZONE3
  tags = {
    Name = "dov-priv-3"
  }
}

resource "aws_internet_gateway" "dove-IGW" {
  vpc_id = aws_vpc.dove.id
  tags = {
    Name = "dove-IGW"
  }
}

resource "aws_route_table" "dov-pub-RT" {
  vpc_id = aws_vpc.dove.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dove-IGW.id
  }

  tags = {
    Name = "dov-pub-RT"
  }
}

resource "aws_route_table_association" "dov-pub-1-a" {
  subnet_id      = aws_subnet.dov-pub-1.id
  route_table_id = aws_route_table.dov-pub-RT.id
}

resource "aws_route_table_association" "dov-pub-2-a" {
  subnet_id      = aws_subnet.dov-pub-2.id
  route_table_id = aws_route_table.dov-pub-RT.id
}

resource "aws_route_table_association" "dov-pub-3-a" {
  subnet_id      = aws_subnet.dov-pub-3.id
  route_table_id = aws_route_table.dov-pub-RT.id
}