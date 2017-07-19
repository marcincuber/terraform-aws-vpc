variable "account_id" {
    description = "AWS Account ID dev or prod"
}

variable "elastic_ip_allocation_id" {
    description = "Allocation ID for elastic IP attached to NAT Gateway"
}

variable "aws_region" {
    description = "Region for the VPC (Ireland)"
    default = "eu-west-1"
}

variable "vpc_cidr" {
    description = "CIDR for the whole VPC"
    default = "10.10.0.0/16"
}

variable "public_subnet_cidr_a" {
    description = "CIDR for the Public Subnet"
    default = "10.10.1.0/24"
}

variable "public_subnet_cidr_b" {
    description = "CIDR for the Public Subnet"
    default = "10.10.2.0/24"
}

variable "public_subnet_cidr_c" {
    description = "CIDR for the Public Subnet"
    default = "10.10.3.0/24"
}

variable "private_subnet_cidr_a" {
    description = "CIDR for the Private Subnet"
    default = "10.10.11.0/24"
}

variable "private_subnet_cidr_b" {
    description = "CIDR for the Private Subnet"
    default = "10.10.12.0/24"
}

variable "private_subnet_cidr_c" {
    description = "CIDR for the Private Subnet"
    default = "10.10.13.0/24"
}