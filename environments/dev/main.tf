provider "aws" {
  region = var.aws_region

  default_tags {
    tags = merge(var.tags, {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "terraform"
    })
  }
}

locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

module "vpc" {
  source = "../../modules/vpc"

  name_prefix          = local.name_prefix
  vpc_cidr             = var.vpc_cidr
  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  enable_nat_gateway   = true
  single_nat_gateway   = true # dev: single shared NAT gateway to save cost
  tags                 = var.tags
}

module "data_bucket" {
  source = "../../modules/s3"

  bucket_name        = var.data_bucket_name
  versioning_enabled = true
  force_destroy      = var.force_destroy_bucket
  tags               = var.tags
}

module "iam" {
  source = "../../modules/iam"

  name_prefix    = local.name_prefix
  s3_bucket_arns = [module.data_bucket.bucket_arn]
  enable_ssm     = true
  tags           = var.tags
}

module "ec2" {
  source = "../../modules/ec2"

  name_prefix                 = local.name_prefix
  vpc_id                      = module.vpc.vpc_id
  subnet_ids                  = module.vpc.private_subnet_ids
  instance_type                = var.instance_type
  min_size                    = var.min_size
  max_size                    = var.max_size
  desired_capacity            = var.desired_capacity
  instance_profile_name       = module.iam.instance_profile_name
  allowed_ingress_cidr_blocks = [var.vpc_cidr]
  app_port                    = var.app_port
  tags                        = var.tags
}
