environment  = "prod"
aws_region   = "us-east-1"
project_name = "platform"

vpc_cidr              = "10.1.0.0/16"
azs                   = ["us-east-1a", "us-east-1b", "us-east-1c"]
public_subnet_cidrs   = ["10.1.0.0/24", "10.1.1.0/24", "10.1.2.0/24"]
private_subnet_cidrs  = ["10.1.10.0/24", "10.1.11.0/24", "10.1.12.0/24"]

instance_type    = "t3.small"
min_size         = 2
max_size         = 6
desired_capacity = 3
app_port         = 8080

data_bucket_name     = "platform-prod-data-bucket-change-me"
force_destroy_bucket = false

tags = {
  Owner      = "platform-team"
  CostCenter = "engineering-prod"
}
