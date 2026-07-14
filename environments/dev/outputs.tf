output "vpc_id" {
  value = module.vpc.vpc_id
}

output "data_bucket_arn" {
  value = module.data_bucket.bucket_arn
}

output "autoscaling_group_name" {
  value = module.ec2.autoscaling_group_name
}
