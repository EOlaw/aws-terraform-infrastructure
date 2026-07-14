variable "name_prefix" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  description = "Subnets the auto scaling group may launch instances into."
  type        = list(string)
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

variable "instance_profile_name" {
  description = "IAM instance profile name to attach (from the iam module)."
  type        = string
}

variable "allowed_ingress_cidr_blocks" {
  description = "CIDR blocks allowed to reach the application port. Use the VPC CIDR or an ALB security group in front of this, not 0.0.0.0/0, in production."
  type        = list(string)
  default     = []
}

variable "app_port" {
  type    = number
  default = 8080
}

variable "user_data" {
  description = "Optional cloud-init/user-data script for instance bootstrap."
  type        = string
  default     = <<-EOT
    #!/bin/bash
    set -euo pipefail
    yum update -y
    amazon-linux-extras install -y docker || dnf install -y docker
    systemctl enable --now docker
  EOT
}

variable "tags" {
  type    = map(string)
  default = {}
}
