
/*==== The VPC ======*/
resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name        = "${var.environment}-vpc"
    Environment = "${var.environment}"
  }
}
/*==== Subnets ======*/
/* Internet gateway for the public subnet */
resource "aws_internet_gateway" "ig" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags = {
    Name        = "${var.environment}-igw"
    Environment = "${var.environment}"
  }
}
/* Elastic IP for NAT */
resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.ig]
}
/* NAT */
resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nat_eip.id}"
  subnet_id     = "${element(aws_subnet.public_subnet.*.id, 0)}"
  depends_on    = [aws_internet_gateway.ig]
  tags = {
    Name        = "nat"
    Environment = "${var.environment}"
  }
}
/* Public subnet */
resource "aws_subnet" "public_subnet" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  count                   = "${length(var.public_subnets_cidr)}"
  cidr_block              = "${element(var.public_subnets_cidr,   count.index)}"
  availability_zone       = "${element(var.availability_zones,   count.index)}"
  map_public_ip_on_launch = true
  tags = {
    Name        = "${var.environment}-${element(var.availability_zones, count.index)}-      public-subnet"
    Environment = "${var.environment}"
  }
}
/* Private subnets */
resource "aws_subnet" "private_subnet_app" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  count                   = "${length(var.private_app_subnets_cidr)}"
  cidr_block              = "${element(var.private_app_subnets_cidr, count.index)}"
  availability_zone       = "${element(var.availability_zones,   count.index)}"
  map_public_ip_on_launch = false
  tags = {
    Name        = "${var.environment}-${element(var.availability_zones, count.index)}-private-app-subnet"
    Environment = "${var.environment}"
  }
}

resource "aws_subnet" "private_subnet_database" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  count                   = "${length(var.private_db_subnets_cidr)}"
  cidr_block              = "${element(var.private_db_subnets_cidr, count.index)}"
  availability_zone       = "${element(var.availability_zones,   count.index)}"
  map_public_ip_on_launch = false
  tags = {
    Name        = "${var.environment}-${element(var.availability_zones, count.index)}-private-db-subnet"
    Environment = "${var.environment}"
  }
}


/* Routing table for private subnet */
resource "aws_route_table" "private_app" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags = {
    Name        = "${var.environment}-private-app-route-table"
    Environment = "${var.environment}"
  }
}

/* Routing table for public subnet */
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags = {
    Name        = "${var.environment}-public-route-table"
    Environment = "${var.environment}"
  }
}
resource "aws_route" "public_internet_gateway" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.ig.id}"
}
resource "aws_route" "private_nat_app_gateway" {
  route_table_id         = "${aws_route_table.private_app.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.nat.id}"
}

/* Route table associations */
resource "aws_route_table_association" "public" {
  count          = "${length(var.public_subnets_cidr)}"
  subnet_id      = "${element(aws_subnet.public_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}
resource "aws_route_table_association" "private_app" {
  count          = "${length(var.private_app_subnets_cidr)}"
  subnet_id      = "${element(aws_subnet.private_subnet_app.*.id, count.index)}"
  route_table_id = "${aws_route_table.private_app.id}"
}
/*==== VPC's Default Security Group ======*/
resource "aws_security_group" "default" {
  name        = "${var.environment}-default-sg"
  description = "Default security group to allow inbound/outbound from the VPC"
  vpc_id      = "${aws_vpc.vpc.id}"
  depends_on  = [aws_vpc.vpc]
  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }
  
  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = "true"
  }
  tags = {
    Environment = "${var.environment}"
  }
}

/*==== Database Security Group ======*/
resource "aws_security_group" "rds_sg" {
  name        = "${var.environment}-db-sg"
  description = "Default security group to allow inbound/outbound to the DB"
  vpc_id      = "${aws_vpc.vpc.id}"
  depends_on  = [aws_vpc.vpc]
  ingress {
        from_port = 5432
        to_port = 5432
        protocol = "tcp"
        security_groups = [aws_security_group.default.id]

    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]

    }
  tags = {
    Environment = "${var.environment}"
  }
}
