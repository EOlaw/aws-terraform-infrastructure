# Remote state backend for the dev environment.
#
# NOTE: the actual `backend "s3" {}` block lives in versions.tf alongside
# the provider requirements (Terraform only allows one `terraform {}`
# block with a backend per root module). This file documents the
# one-time bootstrap of the state bucket and lock table, which are
# intentionally NOT managed by this same configuration -- state storage
# should not depend on the state it is storing.
#
#   aws s3api create-bucket --bucket <your-tfstate-bucket> --region us-east-1
#   aws s3api put-bucket-versioning --bucket <your-tfstate-bucket> \
#       --versioning-configuration Status=Enabled
#   aws dynamodb create-table --table-name terraform-locks \
#       --attribute-definitions AttributeName=LockID,AttributeType=S \
#       --key-schema AttributeName=LockID,KeyType=HASH \
#       --billing-mode PAY_PER_REQUEST
