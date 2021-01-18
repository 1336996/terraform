provider "aws" {
  region = "us-east-1"
}

module "s3" {
    source="./modules/s3/"
    frontend_bucket_name=var.frontend_bucket_name
    data_bucket_name=var.data_bucket_name
}

module "network" {
    source="./modules/network/"
}
