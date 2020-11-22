#vpc
resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr
  tags = {
    Name = "dp_insight_vpc"
  }
}

#public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.public_cidr
  availability_zone = "us-east-1c"
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet"
  }
}

#private subnet-1
resource "aws_subnet" "private_subnet_1" {
  #count=length(var.private_cidr)
  vpc_id     = aws_vpc.vpc.id
  availability_zone = "us-east-1b"
  cidr_block = var.private_cidr[0]
  tags = {
    Name = "private_subnet_1"
  }
}

#private subnet-2

resource "aws_subnet" "private_subnet_2" {
  #count=length(var.private_cidr)
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.private_cidr[1]
  availability_zone = "us-east-1a"
  tags = {
    Name = "private_subnet_2"
  }
}
#internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "dp_insight_igw"
  }
}

#elastic_ip

resource "aws_eip" "nat" {
  vpc      = true
  tags = {
    Name = "dp_insight_eip"
  }
}

#nat_gateway
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet.id
  depends_on = [aws_internet_gateway.gw]
  tags = {
    Name = "dp_insight_nat_gw"
  }
}


#public_route_table

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public_route_table"
  }
}

#private_route_table-1

resource "aws_route_table" "private_route_table" {
  #count=2
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id  = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "private_route_table"
  }
}

#route associations_public

resource "aws_route_table_association" "public_subnet_route_assc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
  
}

#route associations_private_1
resource "aws_route_table_association" "private_subnet_route_assc_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table.id
 
}

#route associations_private_2
resource "aws_route_table_association" "private_subnet_route_assc_2" {

  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_table.id


}

resource "aws_security_group" "alb_sg" {
  name        = "dp-insight-alb-sg"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "ssh"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dp_insight_alb_sg"
  }
}

#route 53
resource "aws_route53_zone" "hosted_zone" {
  name = "rohit123.com"
   tags = {
    Name = "dp_insight"
  }
}

resource "aws_route53_record" "rcrd" {
  zone_id = aws_route53_zone.hosted_zone.zone_id
  name    = "dev.rohit123.com"
  type    = "A"
  ttl     = "3000"
  records = ["1.1.1.1"]
}

#application load balancer

resource "aws_lb" "alb" {
  name               = "dp-insight-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.private_subnet_1.id,aws_subnet.private_subnet_2.id]

  


}
#application load balancer_target_grp

resource "aws_lb_target_group" "alb_trgt_grp" {
  name     = "dp-insight"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
  target_type = "ip"
  health_check {
    healthy_threshold = "3"
    interval = "30"
    protocol = "HTTP"
    matcher = "200"
    timeout = "3"
    path = "/"
    unhealthy_threshold = "2"
  }
}

#application load balancer_listener

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.alb.arn
  port              = var.app_port
  protocol          = "HTTP"
  #ssl_policy        = "ELBSecurityPolicy-2016-08"
  #certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_trgt_grp.arn
  }
}
