# AWS Terraform Infrastructure

### Version-controlled, repeatable AWS infrastructure as code - VPC, compute, storage, and IAM provisioned entirely through Terraform, with a dedicated multi-environment layout for dev and prod.

This repository is a standalone Infrastructure-as-Code project: no application
code lives here. It exists to answer one question reproducibly - "give me a
secure, tagged, right-sized AWS environment for an application, from a clean
account, in one command" - and to make every change to that environment
reviewable as a diff instead of a console click.

## What's implemented
- **VPC module** (`modules/vpc`) - a VPC with public and private subnets spread across multiple AZs, an Internet Gateway, NAT Gateway(s) for private-subnet egress, and separate route tables per tier.
- **EC2 module** (`modules/ec2`) - an Auto Scaling Group behind a launch template (IMDSv2-enforced, encrypted EBS volumes), a scoped security group, and a target-tracking scaling policy on CPU utilization.
- **S3 module** (`modules/s3`) - a private, encrypted, versioned bucket with a lifecycle policy (Standard -> Standard-IA -> Glacier) and a public-access block enabled by default.
- **IAM module** (`modules/iam`) - an EC2 instance role scoped to exactly the S3 buckets it needs (no `s3:*` on `*`), with SSM Session Manager access instead of SSH key management, and CloudWatch agent permissions.
- **Two supported layouts**: a single-environment quickstart at the repo root (`main.tf` + a `-var-file`), and a fully independent `environments/dev` / `environments/prod` split - each with its own state file, backend, and tfvars - for a real multi-environment setup.
- **Remote state**: S3 backend + DynamoDB state locking, documented (not auto-created - state storage shouldn't depend on the state it stores).

## Project layout

```
aws-terraform-infrastructure/
|-- modules/
| |-- vpc/ # VPC, subnets, IGW, NAT gateway(s), route tables
| |-- ec2/ # Launch template, ASG, security group, scaling policy
| |-- s3/ # Encrypted, versioned, lifecycle-managed bucket
| `-- iam/ # Scoped EC2 instance role + instance profile
|-- environments/
| |-- dev/ # Independent root module: 2 AZs, single NAT, t3.micro
| `-- prod/ # Independent root module: 3 AZs, NAT per AZ, t3.small, min 2 instances
|-- main.tf # Root quickstart - wires all 4 modules together
|-- variables.tf
|-- outputs.tf
|-- versions.tf # Terraform + AWS provider version constraints
`-- .gitignore
```

## How to run

### Option A - quickstart (single environment from repo root)

```bash
terraform init
terraform plan -var-file=environments/dev/terraform.tfvars
terraform apply -var-file=environments/dev/terraform.tfvars
```

### Option B - independent per-environment state (recommended for real use)

Each environment under `environments/` is its own root module with its own
backend, so a `terraform apply` in `dev` can never touch `prod` state.

```bash
# one-time: create the remote state bucket + lock table (see environments/dev/backend.tf)

cd environments/dev
terraform init
terraform plan
terraform apply
```

```bash
cd environments/prod
terraform init
terraform plan
terraform apply
```

### Tearing down

```bash
cd environments/dev
terraform destroy
```

## Design notes

- **Least-privilege IAM by construction** - the IAM module only ever grants S3 access to the bucket ARNs it's explicitly passed; there is no wildcard resource in the generated policy.
- **IMDSv2 enforced** - the EC2 launch template sets `http_tokens = "required"`, closing the SSRF-to-credential-theft path that IMDSv1 leaves open.
- **No SSH surface by default** - instances get SSM `AmazonSSMManagedInstanceCore` for shell access via Session Manager; there's no inbound port 22 rule to manage or rotate keys for.
- **Environment isolation is structural, not conventional** - dev and prod are separate root modules with separate state files and separate backend keys, not one root module re-applied with different `-var-file`s against shared state.
- **Everything is tagged** - `default_tags` on the provider block stamps `Environment`, `Project`, and `ManagedBy` onto every resource created by every module, so cost allocation and ownership are never a guessing game.

## Scope

This provisions the compute/network/storage/IAM foundation an application
would run on top of (an ALB, RDS instance, or ECS/EKS layer would sit on top
of this VPC in a fuller platform) - it is intentionally scoped to the "AWS
infrastructure" layer rather than bundled with any one application's
deployment. All resources use `t3` instance families and lifecycle-managed
storage to keep a `terraform apply` of this repository inexpensive to run
end-to-end for review purposes.

**Verification note:** the Terraform HCL in this repository was hand-written
and validated for syntax correctness (`hcl2` parse-clean across all 26 `.tf`
files) in an environment without network access to the Terraform provider
registry, so `terraform validate` / `terraform plan` against a live AWS
account has not been executed by the author of this commit. Running
`terraform init && terraform validate` is recommended before the first
`apply` in your own account.
