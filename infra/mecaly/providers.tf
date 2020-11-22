terraform {
  required_providers {
    aws = {
      version = "3.0.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}
