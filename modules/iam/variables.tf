variable "name_prefix" {
  description = "Prefix applied to all resource names created by this module."
  type        = string
}

variable "s3_bucket_arns" {
  description = "ARNs of S3 buckets the EC2 role should be granted read/write access to."
  type        = list(string)
  default     = []
}

variable "enable_ssm" {
  description = "Attach the AWS-managed SSM policy so instances can be managed via Session Manager instead of SSH."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Common tags applied to all resources."
  type        = map(string)
  default     = {}
}
