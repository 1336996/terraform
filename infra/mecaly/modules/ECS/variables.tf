variable "repo_name" {
    type = string
}
variable "cluster_name" {
    type = string
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
variable "subnet_ids" {
   type=list(string)
}
variable "target_group" {
    type = string
}
variable "worker_service_name" {
    type = string
}
variable "security_group" {
    type=list(string)
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
*/