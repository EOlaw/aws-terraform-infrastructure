variable "environment" {
  description = "Deployment environment name (dev, staging, prod). Drives resource naming and tagging."
  type        = string
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "platform"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "azs" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "min_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 3
}

variable "desired_capacity" {
  type    = number
  default = 2
}

variable "app_port" {
  type    = number
  default = 8080
}

variable "data_bucket_name" {
  description = "Globally-unique S3 bucket name for application data."
  type        = string
}

variable "force_destroy_bucket" {
  type    = bool
  default = false
}

variable "tags" {
  type    = map(string)
  default = {}
}
