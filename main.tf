terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.7"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "My VPC"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "My VPC - Internet Gateway"
  }
}

# Public Subnets - 2 
resource "aws_subnet" "public" {
  count             = length(var.subnets_pub)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(var.subnets_pub, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "Subnet-${count.index + 1}"
  }
}

/*
resource "aws_subnet" "subnet2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnets_pub
  availability_zone = "us-east-1b"

  tags = {
    Name = "Public Subnet 2"
  }
}
*/

# Route Table: attach Internet Gateway
resource "aws_route_table" "pubroute" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public Subnet Route Table"
  }
}

# Route table associations with public subnets
resource "aws_route_table_association" "pubroute_assoc" {
  count          = length(var.subnets_pub)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.pubroute.id
}

# NAT Gateway - 2
resource "aws_eip" "nat_gw_eip" {
  count = length(var.subnets_pub)
  vpc   = true
}

resource "aws_nat_gateway" "ngw" {
  count         = length(var.subnets_pub)
  allocation_id = element(aws_eip.nat_gw_eip.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  depends_on = [ aws_internet_gateway.igw ]

  tags = {
    Name = "NAT-${count.index + 1}"
  }
}


# S3 Bucket
resource "aws_s3_bucket" "s3_bucket" {
  bucket = "d37049s"
  acl    = "private"

  tags = {
    Name = "My Bucket"
  }
}


# Application Load Balancer
resource "aws_lb" "alb" {
  name               = "jira-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_jira.id]
  subnets            = aws_subnet.public.*.id
}

# Private Subnets - 2 
resource "aws_subnet" "private" {
  count             = length(var.subnets_pri)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(var.subnets_pri, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "Subnet-${count.index + 1}"
  }
}


# Route table for private subnets 
resource "aws_route_table" "priroute" {
  count  = length(var.subnets_pri)
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.ngw.*.id, count.index)
  }

  tags = {
    Name = "Private Subnet Route Table"
  }
}

# Route table associations with private subnets
resource "aws_route_table_association" "priroute_assoc" {
  count          = length(var.subnets_pri)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.priroute.*.id, count.index)
}

/*
# Uploading file
resource "aws_s3_bucket_object" "object" {
  bucket = "d37049s"
  acl    = "private"

  tags = {
    "Name" = "Dev"
  }
}

# Access Logs
access_logs {
    bucket  = aws_s3_bucket.lb_logs.bucket
    prefix  = "alb_logs"
    enabled = true
  }

  resource "aws_route_table" "route_nat" {
    vpc_id = aws_vpc.vpc.id

    route {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.ngw.id
    }

    tags = {
      Name = "Route Table for NAT"
    }
  }

  resource "aws_route_table_association" "route_nat-assoc" {
    subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
    route_table_id = aws_route_table.route_nat.id
  }
  Error: Failure configuring LB attributes: InvalidConfigurationRequest: Access Denied for bucket:
d37049. Please check S3bucket permission
        status code: 400, request id: 4bf3db10-0900-4697-9784-cc610f65564e



Error: Error opening S3 bucket object source (path/to/file): open path/to/file: The system cannot find the path specified.
*/
