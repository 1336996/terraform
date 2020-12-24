provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "test" {
  cidr_block = "10.0.0.0/16"
}
/*
locals {
  try = flatten(var.type)
}*/
resource "aws_instance" "web" {
  ami           = "ami-04d29b6f966df1537" 
#  for_each = local.try
  for_each = var.type
  instance_type = each.value

  tags = {
    Name = each.key
  }
}
