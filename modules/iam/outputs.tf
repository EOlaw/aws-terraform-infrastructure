output "role_arn" {
  value = aws_iam_role.ec2_role.arn
}

output "role_name" {
  value = aws_iam_role.ec2_role.name
}

output "instance_profile_name" {
  value = aws_iam_instance_profile.ec2_profile.name
}
