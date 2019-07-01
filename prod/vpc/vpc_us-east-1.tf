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
# internet gateway for region us-east-1
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_internet_gateway" "prod-igw"{
  vpc_id = "${aws_vpc.prod-vpc.id}"
  tags = {
    Name = "prod-igw"
  }
  # lifecycle {
  #   create_before_destroy = false
  # }
}
# ---------------------------------------------------------------------------------------------------------------------
# route table for IGW (QUESTION: Can I use the default route table or create this new one?)
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_route_table" "route-table" {
  vpc_id = "${aws_vpc.prod-vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.prod-igw.id}"
  }
  tags = {
    Name = "prod-route-igw"
  }
}
# ---------------------------------------------------------------------------------------------------------------------
# route table association with public subnets
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_route_table_association" "prod-rt-assoc-1" {
  subnet_id = "${aws_subnet.prod_pub_subnet_us-east-1a.id}"
  route_table_id = "${aws_route_table.route-table.id}"
}
resource "aws_route_table_association" "prod-rt-assoc-2" {
  subnet_id = "${aws_subnet.prod_pub_subnet_us-east-1b.id}"
  route_table_id = "${aws_route_table.route-table.id}"
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
