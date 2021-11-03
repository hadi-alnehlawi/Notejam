variable "env" { default = "production"}

variable "db_password" {}

variable "db_username" {}

variable "db_name" {}

variable "project" { default = "Notejam" }

variable "vpc_name" {}
variable "snapshot_s3_name" {}

variable "lambda_name" {}

variable "snapshot_s3_role" {}

variable "snapshot_s3_policy" {}

variable "lambda_role" {}

variable "lambda_policy" {}

variable "snapshot_kms" {}

variable "sg_name" {}

variable "eks_name" {}

variable "vpc_cidr"{ default="10.0.0.0/16" }

variable "public_subnets" { default=["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]}

variable "private_subnets" { default=["10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]}

variable "database_subnets" { default=["10.0.7.0/24", "10.0.8.0/24", "10.0.9.0/24"]}

variable "aws_region" { default = "sa-east-1" }

variable "aws_azs" { default = ["sa-east-1a", "sa-east-1b", "sa-east-1c"] }
variable "aws_cred_file" {}

variable "aws_profile" {}

variable "ec2_type" {}
variable "db_instance" {}