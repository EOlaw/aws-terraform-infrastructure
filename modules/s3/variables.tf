variable "bucket_name" {
  description = "Globally-unique S3 bucket name."
  type        = string
}

variable "versioning_enabled" {
  type    = bool
  default = true
}

variable "force_destroy" {
  description = "Allow Terraform to delete the bucket even if it contains objects. Keep false in prod."
  type        = bool
  default     = false
}

variable "lifecycle_transition_days" {
  description = "Days after which current-version objects transition to STANDARD_IA."
  type        = number
  default     = 30
}

variable "lifecycle_glacier_days" {
  description = "Days after which current-version objects transition to GLACIER."
  type        = number
  default     = 90
}

variable "noncurrent_version_expiration_days" {
  description = "Days after which noncurrent (overwritten/deleted) object versions are permanently removed."
  type        = number
  default     = 365
}

variable "tags" {
  type    = map(string)
  default = {}
}
