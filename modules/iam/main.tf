locals {
  common_tags = merge(var.tags, {
    Module = "iam"
  })
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_role" {
  name               = "${var.name_prefix}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
  tags               = local.common_tags
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.name_prefix}-ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}

# Least-privilege S3 access scoped to the specific bucket ARNs passed in,
# rather than a wildcard "s3:*" on "*" -- the buckets this role can touch
# are explicit and reviewable.
data "aws_iam_policy_document" "s3_access" {
  count = length(var.s3_bucket_arns) > 0 ? 1 : 0

  statement {
    sid     = "ListBuckets"
    effect  = "Allow"
    actions = ["s3:ListBucket"]
    resources = var.s3_bucket_arns
  }

  statement {
    sid    = "ReadWriteObjects"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = [for arn in var.s3_bucket_arns : "${arn}/*"]
  }
}

resource "aws_iam_policy" "s3_access" {
  count       = length(var.s3_bucket_arns) > 0 ? 1 : 0
  name        = "${var.name_prefix}-ec2-s3-access"
  description = "Scoped S3 read/write access for ${var.name_prefix} EC2 instances."
  policy      = data.aws_iam_policy_document.s3_access[0].json
}

resource "aws_iam_role_policy_attachment" "s3_access" {
  count      = length(var.s3_bucket_arns) > 0 ? 1 : 0
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_access[0].arn
}

resource "aws_iam_role_policy_attachment" "ssm" {
  count      = var.enable_ssm ? 1 : 0
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}
