variable "env" {
  default = "production"
}

variable "project" {
  default = "Notejam"
}

variable "aws_region" {}

variable "aws_cred_file" {}

variable "aws_profile" {}
resource "random_integer" "id" {
  min     = 100000
  max     = 999999
}

provider "aws" {
  region                  = var.aws_region
  shared_credentials_file = var.aws_cred_file
  profile                 = var.aws_profile
}



# module "db" {
#   source               = "terraform-aws-modules/rds/aws"
#   version              = "~> 3.0"
#   identifier           = "notejam"
#   engine               = "postgres"
#   engine_version       = "11.10-R1"
#   family               = "postgres11" # DB parameter group
#   major_engine_version = "11"         # DB option group
#   instance_class       = "db.t3.small"
#   allocated_storage    = 5
#   storage_encrypted    = false
#   name                 = "${db_name}"
#   username             = "${db_username}"
#   password             = "${db_password}"
#   port                 = "5432"

#   iam_database_authentication_enabled = true

#   vpc_security_group_ids = ["sg-${env}-${random_integer.id}"]

#   maintenance_window   = "Mon:00:00-Mon:03:00"
#   backup_window        = "03:00-06:00"

#   # Enhanced Monitoring - see example for details on how to create the role
#   # by yourself, in case you don't want to create it automatically
#   monitoring_interval  = "30"
#   monitoring_role_name = "MyRDSMonitoringRole"
#   create_monitoring_role = true

#   tags = {
#     project = "${project}"
#   }

#   # DB subnet group
#   subnet_ids = ["subnet1-${env}-${random_integer.id}", "subnet2-${env}-${random_integer.id}"]


#   # Database Deletion Protection
#   deletion_protection     = false
#   backup_retention_period = 0
#   skip_final_snapshot     = true


#   parameters = [
#     {
#       name  = "character_set_client"
#       value = "utf8mb4"
#     },
#     {
#       name  = "character_set_server"
#       value = "utf8mb4"
#     }
#   ]

#   options = [
#     {
#       option_name     = "MARIADB_AUDIT_PLUGIN"

#       option_settings = [
#         {
#           name  = "SERVER_AUDIT_EVENTS"
#           value = "CONNECT"
#         },
#         {
#           name  = "SERVER_AUDIT_FILE_ROTATIONS"
#           value = "37"
#         },
#       ]
#     },
#   ]
# }
# module "db" {
#   source               = "terraform-aws-modules/rds/aws"
#   version              = "~> 3.0"
#   identifier           = "notejam"
#   engine               = "postgres"
#   engine_version       = "11.10-R1"
#   family               = "postgres11" # DB parameter group
#   major_engine_version = "11"         # DB option group
#   instance_class       = "db.t3.small"
#   allocated_storage    = 5
#   storage_encrypted    = false
#   name                 = "${db_name}"
#   username             = "${db_username}"
#   password             = "${db_password}"
#   port                 = "5432"

#   iam_database_authentication_enabled = true

#   vpc_security_group_ids = ["sg-${env}-${random_integer.id}"]

#   maintenance_window   = "Mon:00:00-Mon:03:00"
#   backup_window        = "03:00-06:00"

#   # Enhanced Monitoring - see example for details on how to create the role
#   # by yourself, in case you don't want to create it automatically
#   monitoring_interval  = "30"
#   monitoring_role_name = "MyRDSMonitoringRole"
#   create_monitoring_role = true

#   tags = {
#     project = "${project}"
#   }

#   # DB subnet group
#   subnet_ids = ["subnet1-${env}-${random_integer.id}", "subnet2-${env}-${random_integer.id}"]


#   # Database Deletion Protection
#   deletion_protection     = false
#   backup_retention_period = 0
#   skip_final_snapshot     = true


#   parameters = [
#     {
#       name  = "character_set_client"
#       value = "utf8mb4"
#     },
#     {
#       name  = "character_set_server"
#       value = "utf8mb4"
#     }
#   ]

#   options = [
#     {
#       option_name     = "MARIADB_AUDIT_PLUGIN"

#       option_settings = [
#         {
#           name  = "SERVER_AUDIT_EVENTS"
#           value = "CONNECT"
#         },
#         {
#           name  = "SERVER_AUDIT_FILE_ROTATIONS"
#           value = "37"
#         },
#       ]
#     },
#   ]
# }