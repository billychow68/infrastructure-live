terraform {
  required_version = ">= 0.12.0"
}
provider "aws" {
  profile = "default"
  region  = "us-east-1"
}
# ---------------------------------------------------------------------------------------------------------------------
# vpc
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_vpc" "prod-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "dedicated"
  tags = {
    Name = "prod-vpc"
  }
}
# ---------------------------------------------------------------------------------------------------------------------
# internet gateway for region us-east-1, route table + routes
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_internet_gateway" "prod-igw"{
  vpc_id = "${aws_vpc.prod-vpc.id}"
  tags = {
    Name = "prod-igw"
  }
}
resource "aws_route_table" "prod-igw-rt" {
  vpc_id = "${aws_vpc.prod-vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.prod-igw.id}"
  }
  tags = {
    Name = "prod-rt-igw"
  }
}
resource "aws_route_table_association" "prod-igw-rt-assoc-1" {
  subnet_id       = "${aws_subnet.prod_pub_subnet_us-east-1a.id}"
  route_table_id  = "${aws_route_table.prod-igw-rt.id}"
}
resource "aws_route_table_association" "prod-igw-rt-assoc-2" {
  subnet_id = "${aws_subnet.prod_pub_subnet_us-east-1b.id}"
  route_table_id = "${aws_route_table.prod-igw-rt.id}"
}
# ---------------------------------------------------------------------------------------------------------------------
# NAT gateway for region us-east-1x, elastic IP, route table + routes
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_eip" "prod-nat-eip-1a" {
  tags = {
    Name = "prod-nat-eip-1a"
  }
}
resource "aws_nat_gateway" "prod-ngw-1a" {
  allocation_id = "${aws_eip.prod-nat-eip-1a.id}"
  subnet_id     = "${aws_subnet.prod_priv_subnet_us-east-1a.id}"
  tags = {
    Name        = "prod-ngw-1a"
  }
  depends_on    = ["aws_internet_gateway.prod-igw"]
}
resource "aws_eip" "prod-nat-eip-1b" {
  tags = {
    Name = "prod-nat-eip-1b"
  }
}
resource "aws_nat_gateway" "prod-ngw-1b" {
  allocation_id = "${aws_eip.prod-nat-eip-1b.id}"
  subnet_id     = "${aws_subnet.prod_priv_subnet_us-east-1b.id}"
  tags = {
    Name        = "prod-ngw-1b"
  }
  depends_on    = ["aws_internet_gateway.prod-igw"]
}
resource "aws_route_table" "prod-ngw-rt" {
  vpc_id = "${aws_vpc.prod-vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.prod-ngw-1a.id}"
  }
  tags = {
    Name = "prod-rt-igw-1a"
  }
}
resource "aws_route_table_association" "prod-ngw-rt-assoc-1a" {
  subnet_id = "${aws_subnet.prod_priv_subnet_us-east-1a.id}"
  route_table_id = "${aws_route_table.prod-ngw-rt.id}"
}
resource "aws_route_table_association" "prod-ngw-rt-assoc-1b" {
  subnet_id = "${aws_subnet.prod_priv_subnet_us-east-1b.id}"
  route_table_id = "${aws_route_table.prod-ngw-rt.id}"
}
# ---------------------------------------------------------------------------------------------------------------------
# public and private subnets for AZ us-east-1a
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_subnet" "prod_pub_subnet_us-east-1a" {
 cidr_block        = "10.0.1.0/24"
 vpc_id            = "${aws_vpc.prod-vpc.id}"
 availability_zone = "us-east-1a"
 tags = {
   Name = "prod_pub_subnet_us-east-1a"
 }
}
resource "aws_subnet" "prod_priv_subnet_us-east-1a" {
 cidr_block        = "10.0.2.0/24"
 vpc_id            = "${aws_vpc.prod-vpc.id}"
 availability_zone = "us-east-1a"
 tags = {
   Name = "prod_priv_subnet_us-east-1a"
 }
}
# ---------------------------------------------------------------------------------------------------------------------
# public and private subnets for AZ us-east-1b
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_subnet" "prod_pub_subnet_us-east-1b" {
 cidr_block        = "10.0.3.0/24"
 vpc_id            = "${aws_vpc.prod-vpc.id}"
 availability_zone = "us-east-1b"
 tags = {
   Name = "prod_pub_subnet_us-east-1b"
 }
}
resource "aws_subnet" "prod_priv_subnet_us-east-1b" {
 cidr_block        = "10.0.4.0/24"
 vpc_id            = "${aws_vpc.prod-vpc.id}"
 availability_zone = "us-east-1b"
 tags = {
   Name = "prod_priv_subnet_us-east-1b"
 }
}
