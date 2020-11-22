variable "family" {
    type=string
}
variable "allocated_storage" {
    type=string
}
variable "storage_type" {
    type=string
}
variable "engine" {
    type=string
}
variable "engine_version" {
    type=string
}
variable "instance_class" {
    type=string
}
variable "username" {
    type=string
}
variable "password" {
    type=string
}
variable "repo_name" {
    type = string
}
variable "cluster_name" {
    type = string
}
variable "vpc_cidr" {
    type=string
}
variable "public_cidr" {
    type=string
}
variable "private_cidr" {
    type=list
}
variable "frontend_bucket_name" {
    type=string
}

variable "data_bucket_name" {
    type=string
}

variable "identifier" {
    type=string
}
variable "name" {
    type=string
}
variable "dbname" {
    type=string
}

variable "app_port" {
    type=string
}
variable "worker_app_name" {
    type = string
}
variable "count1" {
    type = string
}
variable "launch_type" {
    type = string
}
variable "worker_service_name" {
    type = string
}
variable "api_app_name" {
    type = string
}
variable "api_service_name" {
    type = string
}
/*
variable "capacity_providers" {
    type = string
}
variable "worker_container_port" {
    type = string
}
variable "host_port" {
    type = string
}
variable "fargate_cpu" {
    
}
variable "fargate_memory" {
  
}
variable "worker_app_image" {
    type = string
}
*/