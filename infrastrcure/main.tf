variable "env" { default = "production"}

variable "db_password" {}

variable "db_username" {}

variable "db_name" {}

variable "project" { default = "Notejam" }

variable "vpc_name" {}

variable "sg_name" {}

variable "vpc_cidr"{ default="10.0.0.0/16" }

variable "public_subnets" { default=["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]}

variable "private_subnets" { default=["10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]}

variable "database_subnets" { default=["10.0.7.0/24", "10.0.8.0/24", "10.0.9.0/24"]}

variable "aws_region" { default = "sa-east-1" }

variable "aws_azs" { default = ["sa-east-1a", "sa-east-1b", "sa-east-1c"] }
variable "aws_cred_file" {}

variable "aws_profile" {}

resource "random_uuid" "uuid" {}

provider "aws" {
  region                  = var.aws_region
  shared_credentials_file = var.aws_cred_file
  profile                 = var.aws_profile
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name = var.vpc_name
  cidr = var.vpc_cidr
  azs  = var.aws_azs
  public_subnets   = var.public_subnets
  private_subnets  = var.private_subnets
  database_subnets = var.database_subnets
  # Sometimes it is handy to have public access to RDS instances (it is not recommended for production)
  create_database_subnet_group            = true
  create_database_subnet_route_table      = true
  create_database_internet_gateway_route  = true
  enable_dns_hostnames                    = true
  enable_dns_support                      = true
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4"
  name        = var.sg_name
  description = "Complete PostgreSQL example security group"
  vpc_id      = module.vpc.vpc_id


  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "PostgreSQL access from within VPC"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
  ]
}

module "rds" {
  source               = "terraform-aws-modules/rds/aws"
  version              = "~> 3.0"
  identifier           = "notejamdbinstance"
  engine               = "postgres"
  engine_version       = "11.10"
  family               = "postgres11" # DB parameter group
  major_engine_version = "11"         # DB option group
  instance_class       = "db.t3.small"
  allocated_storage    = 5
  storage_encrypted    = false
  name                 = var.db_name
  username             = var.db_username
  password             = var.db_password
  port                 = "5432"


  iam_database_authentication_enabled     = true


  vpc_security_group_ids = [module.security_group.security_group_id]

  # Enhanced Monitoring - see example for details on how to create the role
  # by yourself, in case you don't want to create it automatically
  monitoring_interval  = "30"
  monitoring_role_name = "MyRDSMonitoringRole"
  create_monitoring_role = true

  tags = {
    project = var.project
  }

  # DB subnet group
  # subnet_ids = ["subnet1-${var.env}-${random_uuid.uuid.result}", "subnet2-${var.env}-${random_uuid.uuid.result}"]
  subnet_ids = module.vpc.database_subnets

  # Database Deletion Protection
  deletion_protection     = false
  backup_retention_period = 0
  skip_final_snapshot     = true

  parameters = [
      {
        name  = "autovacuum"
        value = 1
      },
      {
        name  = "client_encoding"
        value = "utf8"
      }
    ]
}
