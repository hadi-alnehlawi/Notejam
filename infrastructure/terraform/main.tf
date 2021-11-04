
resource "random_uuid" "uuid" {}

provider "aws" {
  region                  = var.aws_region
  shared_credentials_file = var.aws_cred_file
  profile                 = var.aws_profile
}

# S3 Buckets

resource "aws_s3_bucket" "snapshot_s3" {
  bucket = "${var.snapshot_s3_name}-${random_uuid.uuid.result}"
  acl    = "private"
  tags = {
    env         = var.env
    project     = var.project
  }
}

# IAM 
resource "aws_iam_policy" "snapshot_s3_policy" {
  name        = var.snapshot_s3_policy
  path        = "/"
  description = "it would be used by snapshot to copy into s3"
  policy = jsonencode({
    Version = "2012-10-17"
    "Statement": [
        {
            "Sid": "ExportPolicy",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject*",
                "s3:ListBucket",
                "s3:GetObject*",
                "s3:DeleteObject*",
                "s3:GetBucketLocation"
            ],
            "Resource": [
                "arn:aws:s3:::${aws_s3_bucket.snapshot_s3.id}",
                "arn:aws:s3:::${aws_s3_bucket.snapshot_s3.id}/*"
            ]
        }
    ]
  })
}
resource "aws_iam_role" "snapshot_s3_role" {
  name = var.snapshot_s3_role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
         "Statement": [
       {
         "Effect": "Allow",
         "Principal": {
            "Service": "export.rds.amazonaws.com"
          },
         "Action": "sts:AssumeRole"
       }
     ] 
    }
    )
  tags = {
    project = var.project
  }
}

resource "aws_iam_role_policy_attachment" "snapshot_attachement" {
  role       = aws_iam_role.snapshot_s3_role.name
  policy_arn = aws_iam_policy.snapshot_s3_policy.arn
}

resource "aws_iam_policy" "lambda_policy" {
  name        = var.lambda_policy
  path        = "/"
  description = "it would be used by snapshot to copy into s3"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "Stmt1635981728067",
        "Action": "events:*",
        "Effect": "Allow",
        "Resource": "*"
      },
      {
        "Sid": "Stmt1635982858263",
        "Action": [
          "rds:CreateDBSnapshot"
        ],
        "Effect": "Allow",
        "Resource": "*"
      }
    ]
  })
}
resource "aws_iam_role" "lambda_role" {
  name = var.lambda_role
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  })
  tags = {
    project = var.project
  }
}

resource "aws_iam_role_policy_attachment" "lambda_attachement" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}



# KMS
resource "aws_kms_key" "snapshot_kms" {
  description = "WS KMS key for the server-side encryption. The KMS key is used by the snapshot export task" 
  deletion_window_in_days = 7
  tags = {
    project = var.project
  }
}

resource "aws_kms_alias" "snaptshot_kms_alias" {
  name          = "alias/${var.snapshot_kms}"
  target_key_id = aws_kms_key.snapshot_kms.key_id
}

# VPC
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

# Lambda Function for Snapshot
resource "aws_lambda_function" "snapshot_lambda" {
  filename      = "snapshot.zip"
  source_code_hash = filebase64sha256("snapshot.zip")
  function_name = "snapshot"
  role          = aws_iam_role.lambda_role.arn
  handler       = "snapshot.handler"
  runtime = "nodejs12.x"
  # get the rds instance id and assign to lambda env variable
  environment {
    variables = {
      RDS_INSTANCE = module.rds.db_instance_id
    }
  }
}

# RDS - Postgres DB
module "rds" {
  source               = "terraform-aws-modules/rds/aws"
  version              = "~> 3.0"
  identifier           = "notejamdbinstance"
  engine               = "postgres"
  engine_version       = "12.2"
  family               = "postgres12" # DB parameter group
  major_engine_version = "12"         # DB option group
  instance_class       = var.db_instance
  allocated_storage    = 5
  storage_encrypted    = false
  name                 = var.db_name
  username             = var.db_username
  password             = var.db_password
  port                 = "5432"

  iam_database_authentication_enabled = true

  vpc_security_group_ids = [module.security_group.security_group_id]

  # in production this must be disable
  publicly_accessible = true
 
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
