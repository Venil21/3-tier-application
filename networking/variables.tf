variable "region" {
  description = "AWS Deployment region"
  default = "ap-south-1"
}

variable "environment" {
  description = "AWS Deployment Environment"
  default = "Production"
}

variable "vpc_cidr" {
  description = "VPC CIDR Block"
  default = "10.0.0.0/16"
}

variable "public_subnets_cidr" {
  description = "Public Subnets"
  type = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24","10.0.3.0/24"]
}


variable "private_app_subnets_cidr" {
  description = "Private Subnets for Application"
  type = list(string)
  default = ["10.0.4.0/24", "10.0.5.0/24","10.0.6.0/24"]
}

variable "private_db_subnets_cidr" {
  description = "Private Subnets for Database"
  type = list(string)
  default = ["10.0.7.0/24", "10.0.8.0/24","10.0.9.0/24"]
}

variable "availability_zones" {
  description = "Avaialbility Zones"
  type = list(string)
  default = ["ap-south-1a", "ap-south-1b","ap-south-1c"]
}