#----------------------------|
#Provider Configuration Block|
#----------------------------|

provider "aws" {
  region                  = var.region
  profile                 = var.profile
}

module "base_naming" {
  source = "../common_modules_terraform/bright_naming_conventions"
  app_group = var.project_app_group
  env = var.environment
  ledger = var.project_ledger
  site = var.site
  tier = var.tier
  zone = var.zone
}

#-----------------------------------------------------------|
#Get a list of subnet ids for Elastic Beanstalk Environment |
#-----------------------------------------------------------|

data "aws_subnet_ids" "frontendsubnets" {
  vpc_id = var.vpc_id

  tags = {
    purpose = "frontend"
  }
}

#------------------------------------------------------|
#Create AWS IAM Role for Elastic Beanstalk Environment |
#------------------------------------------------------|

module "iro_elastic_beanstalk_environment" {
  source = "../../common_modules_terraform/bright_naming_conventions"
  base_object = module.base_naming
  type = "iro"
  purpose = "finweb"
}


resource "aws_iam_role" "irofinweb" {
  name = module.iro_elastic_beanstalk_environment.name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = module.iro_elastic_beanstalk_environment.tags
}

#------------------------------------------------------------------------|
#Create AWS IAM Role Policy Attachment for Elastic Beanstalk Environment |
#------------------------------------------------------------------------|

resource "aws_iam_role_policy_attachment" "irpfinweb" {
  role       = aws_iam_role.irofinweb.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

#------------------------------------------------------------------|
#Create AWS IAM Instance Profile for Elastic Beanstalk Environment |
#------------------------------------------------------------------|

module "iip_elastic_beanstalk_environment" {
  source = "../../common_modules_terraform/bright_naming_conventions"
  base_object = module.base_naming
  type = "iip"
  purpose = "finweb"
}

resource "aws_iam_instance_profile" "iipfinweb" {
  name = module.iip_elastic_beanstalk_environment.name
  role = aws_iam_role.irofinweb.name
}

#--------------------------------------------|
#Create AWS Security Group for EC2 Instances |
#--------------------------------------------|

module "sgp_ec2" {
  source = "../../common_modules_terraform/bright_naming_conventions"
  base_object = module.base_naming
  type = "sgp"
  purpose = "finwebec2"
}

resource "aws_security_group" "sgpfinwebec2" {
  name        = module.sgp_ec2.name
  description = "Security group EC2 instance"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP Access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = module.sgp_ec2.tags
}

#-------------------------------------------|
#Create AWS Security Group for LoadBalancer |
#-------------------------------------------|

module "sgp_elb" {
  source = "../../common_modules_terraform/bright_naming_conventions"
  base_object = module.base_naming
  type = "sgp"
  purpose = "finwebelb"
}

resource "aws_security_group" "sgpfinwebelb" {
  name        = module.sgp_elb.name
  description = "Security group for LoadBalancer"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTPS Access"
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

  tags = module.sgp_elb.tags
}

#-----------------------------------------|
#Create AWS Elastic Beanstalk Application |
#-----------------------------------------|

module "bap_elastic_beanstalk" {
  source = "../../common_modules_terraform/bright_naming_conventions"
  base_object = module.base_naming
  type = "bap"
  purpose = "finweb"
}

resource "aws_elastic_beanstalk_application" "bapfinweb" {
  name        = module.bap_elastic_beanstalk.name
  description = "Application For CountyTaxRates Environment"
  tags = module.bap_elastic_beanstalk.tags
}

#-----------------------------------------|
#Create AWS Elastic Beanstalk Environment |
#-----------------------------------------|

module "bev_elastic_beanstalk" {
  source = "../../common_modules_terraform/bright_naming_conventions"
  base_object = module.base_naming
  type = "bev"
  purpose = "finweb"
}

resource "aws_elastic_beanstalk_environment" "bevfinweb" {
  name                = module.bev_elastic_beanstalk.name
  application         = aws_elastic_beanstalk_application.bapfinweb.name
  solution_stack_name = var.solution_stack_name

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = "LoadBalanced"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = aws_security_group.sgpfinwebec2.id
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = var.minsize_asg
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = var.maxsize_asg
  }

  setting {
    namespace = "aws:elbv2:loadbalancer"
    name      = "ManagedSecurityGroup"
    value     = aws_security_group.sgpfinwebelb.id
  }

  setting {
    namespace = "aws:elbv2:loadbalancer"
    name      = "SecurityGroups"
    value     = aws_security_group.sgpfinwebelb.id
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "LoadBalancerType"
    value     = "application"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = var.vpc_id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", data.aws_subnet_ids.frontendsubnets.ids)
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = join(",", data.aws_subnet_ids.frontendsubnets.ids)
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.iipfinweb.id
  }

  tags = module.bev_elastic_beanstalk.tags
}


#-----------------------------------------------|
#Create AWS Route53 data source for hosted zone |
#-----------------------------------------------|

data "aws_route53_zone" "primary" {
  name = var.hosted_zone_name
}

#------------------------------|
#Create AWS Route53 record set |
#------------------------------|

resource "aws_route53_record" "r5rfinweb" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "${aws_elastic_beanstalk_environment.bevfinweb.name}.${data.aws_route53_zone.primary.name}"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_elastic_beanstalk_environment.bevfinweb.endpoint_url]
}