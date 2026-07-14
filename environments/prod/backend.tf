# Remote state backend for the prod environment.
#
# NOTE: the actual `backend "s3" {}` block lives in versions.tf alongside
# the provider requirements. This file documents the one-time bootstrap
# of the state bucket and lock table -- create a SEPARATE key (or bucket)
# from dev so a mistake in one environment's plan can never touch the
# other environment's state file.
#
#   aws s3api create-bucket --bucket <your-tfstate-bucket> --region us-east-1
#   aws s3api put-bucket-versioning --bucket <your-tfstate-bucket> \
#       --versioning-configuration Status=Enabled
#   aws dynamodb create-table --table-name terraform-locks \
#       --attribute-definitions AttributeName=LockID,AttributeType=S \
#       --key-schema AttributeName=LockID,KeyType=HASH \
#       --billing-mode PAY_PER_REQUEST
