output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "data_bucket_arn" {
  value = module.data_bucket.bucket_arn
}

output "ec2_role_arn" {
  value = module.iam.role_arn
}

output "autoscaling_group_name" {
  value = module.ec2.autoscaling_group_name
}
