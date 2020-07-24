variable "region" {
  description = "Name of the AWS Region to be used"
  type        = string
}

variable "profile" {
  description = "Name of the AWS Profile to be used"
  type        = string
}

variable "project_app_group" {
  default = {}
}

variable "project_ledger" {
  default = {}
}

variable "environment" {
  default = {}
}

variable "site" {
  default = {}
}

variable "tier" {
  default = {}
}

variable "zone" {
  default = {}
}

variable "vpc_id" {
  description = "ID of the VPC to be used for Elastic Beanstalk"
  type        = string
}


variable "solution_stack_name" {
  description = "Name of the Solution stack to be used for Elastic Beanstalk"
  type        = string
}

variable "minsize_asg" {
  description = "Minimum size of the autoscaling group to be used for Elastic Beanstalk"
  type        = string
}

variable "maxsize_asg" {
  description = "Maximum size of the autoscaling group to be used for Elastic Beanstalk"
  type        = string
}

variable "hosted_zone_name" {
  description = "Name of the Route53 hosted zone"
  type        = string
}



