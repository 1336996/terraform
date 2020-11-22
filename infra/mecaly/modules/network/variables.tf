variable "vpc_cidr" {
    type=string
}

variable "public_cidr" {
    type=string
}

variable "private_cidr" {
    type=list
}
variable "app_port" {
    type=string
}