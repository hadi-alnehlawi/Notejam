
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


# module "rds" {
#   source               = "terraform-aws-modules/rds/aws"
#   version              = "~> 3.0"
#   identifier           = "notejamdbinstance"
#   engine               = "postgres"
#   engine_version       = "11.10"
#   family               = "postgres11" # DB parameter group
#   major_engine_version = "11"         # DB option group
#   instance_class       = var.db_instance
#   allocated_storage    = 5
#   storage_encrypted    = false
#   name                 = var.db_name
#   username             = var.db_username
#   password             = var.db_password
#   port                 = "5432"

#   iam_database_authentication_enabled = true

#   vpc_security_group_ids = [module.security_group.security_group_id]

#   # in production this must be disable
#   publicly_accessible = true
 
#   tags = {
#     project = var.project
#   }

#   # DB subnet group
#   # subnet_ids = ["subnet1-${var.env}-${random_uuid.uuid.result}", "subnet2-${var.env}-${random_uuid.uuid.result}"]
#   subnet_ids = module.vpc.database_subnets

#   # Database Deletion Protection
#   deletion_protection     = false
#   backup_retention_period = 0
#   skip_final_snapshot     = true

#   parameters = [
#       {
#         name  = "autovacuum"
#         value = 1
#       },
#       {
#         name  = "client_encoding"
#         value = "utf8"
#       }
#     ]
# }
